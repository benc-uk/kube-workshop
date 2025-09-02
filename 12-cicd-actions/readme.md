# 👷 DevOps & CI/CD with Kubernetes

This is an optional section detailing how to set up a continuous integration (CI) and continuous deployment (CD)
pipeline, which will deploy to Kubernetes using Helm.

There are many CI/CD solutions available, we will use GitHub Actions, as it's easy to set up and most developers will
already have GitHub accounts. It assumes familiarity with git and basic GitHub usage such as forking & cloning.

> 📝 NOTE: This is not intended to be full guide or tutorial on GitHub Actions, you would be better off starting
> [here](https://docs.github.com/en/actions/learn-github-actions) or
> [here](https://docs.microsoft.com/en-us/learn/paths/automate-workflow-github-actions/?source=learn).

## 🚩 Get Started with GitHub Actions

We'll use a fork of this repo in order to set things up, but in principle you could also start with an new/empty repo on
GitHub.

- Go to the repo for this workshop [https://github.com/benc-uk/kube-workshop](https://github.com/benc-uk/kube-workshop).
- Fork the repo to your own personal GitHub account, by clicking the 'Fork' button near the top right.
- Clone the forked repo from GitHub using git to your local machine.

Inside the `.github/workflows` directory, create a new file called `build-release.yaml` and paste in the contents:

> 📝 NOTE: This is special directory path used by GitHub Actions!

```yaml
# Name of the workflow
name: CI Build & Release

# Triggers for running
on:
  workflow_dispatch: # This allows manually running from GitHub web UI
  push:
    branches: ["main"] # Standard CI trigger when main branch is pushed

env:
  PLACEHOLDER: "This is a placeholder"

# One job for building the app
jobs:
  buildJob:
    name: "Build & push images"
    runs-on: ubuntu-latest
    steps:
      # Checkout code from another repo on GitHub
      - name: "Checkout app code repo"
        uses: actions/checkout@v5
        with:
          repository: benc-uk/nanomon
```

The comments in the YAML should hopefully explain what is happening. But in summary this will run a short single step
job that just checks out the code of the Nanomon app repo. The name and filename do not reflect the current function,
but the intent of what we are building towards.

Now commit the changes and push to the main branch, yes this is not a typical way of working, but adding a code review
or PR process would merely distract from what we are doing, and massively slow us down.

The best place to check the status is from the GitHub web site and in the 'Actions' within your forked repo, e.g.
`https://github.com/{your-github-user}/kube-workshop/actions` you should be able to look at the workflow run, the
status, plus output & other details.

> 📝 NOTE: It's unusual for the code you are building to be a in separate repo from the workflow(s), in most cases they
> will be in the same code base, however it doesn't really make any difference in this case.

If that all worked, you should see a green tick and the job should have completed in under a minute.

Now to build the Docker images for the app, we will use a Docker compose file that is already in the repo at
`build/compose.yaml`. This is a multi-service compose file that will build all the images in one go.

Replace the `env:` section at the top of the workflow YAML with this, changing the `__ACR_NAME__` to the name of your
existing & deployed ACR.

<!-- {% raw %} -->

```yaml
env:
  IMAGE_NAME: "nanomon"
  IMAGE_REG: "__ACR_NAME__.azurecr.io"
  IMAGE_TAG: "${{ github.sha }}"
  VERSION: "${{ github.sha }}"
  BUILD_INFO: "CI Build from GitHub Actions"
```

<!-- {% endraw %} -->

Also add this step to the workflow, under the `steps:` section, it will need indenting to the correct level:

```yaml
- name: "Build images"
  run: |
    docker compose -f build/compose.yaml build api frontend runner
```

Commit and push the changes to main, then check the status of the workflow again. It should take a little longer this
time, as it is building the images. If all goes well you should see a green tick again.

## ⌨️ Set Up GitHub CLI

Install the GitHub CLI, this will make setting up the secrets required in the next part much more simple. All commands
below assume you are running them from within the path of the cloned repo on your local machine.

- On MacOS: [https://github.com/cli/cli#macos](https://github.com/cli/cli#macos)
- On Ubuntu/WSL: `curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/gh.sh | bash`

Now login using the GitHub CLI, follow the authentication steps when prompted:

```bash
gh auth login
```

Once the CLI is set up it, we can use it to create a
[secret](https://docs.github.com/en/actions/security-guides/encrypted-secrets) within your repo, called `ACR_PASSWORD`.
We'll reference this secret in the next section. This combines the Azure CLI and GitHub CLI into one neat way to get the
credentials:

```bash
gh secret set ACR_PASSWORD --body "$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)"
```

## 📦 Add CI Steps For Image Building

The workflow, doesn't really do much, the application gets built and images created but they go nowhere. So let's update
the workflow YAML to push the images to our Azure Container Registry.

<!-- {% raw %} -->

Add extra environment variables to the `env:` section at the top of the workflow YAML

```yaml
env:
  ACR_PASSWORD: "${{ secrets.ACR_PASSWORD }}"
  ACR_USERNAME: "__ACR_NAME__"
```

In the `steps:` section of the `buildJob`, add the following two steps after the "Build images" step, again indenting
correctly:

```yaml
- name: "Login to ACR"
  uses: docker/login-action@v3
  with:
    registry: ${{ env.IMAGE_REG }}
    username: ${{ env.ACR_USERNAME }}
    password: ${{ secrets.ACR_PASSWORD }}

- name: "Push images"
  run: |
    docker compose -f build/compose.yaml push api frontend runner
```

<!-- {% endraw %} -->

Save the file, commit and push to main just as before. Then check the status as before from the GitHub web site. If all
goes well you should see a green tick again.

The workflow now does three important things:

- Builds the container images for the API, frontend and runner components of the app
- Logs into the ACR using the credentials stored in a GitHub secret
- Pushes the images to the ACR

The "Build & push images" job and the workflow should take around 2~3 minutes to complete.

## 🔌 Connect To Kubernetes

We'll be using an approach of "pushing" changes from the workflow pipeline to the cluster, really exactly the same as we
have been doing from our local machines with `kubectl` and `helm` commands.

To do this we need a way to authenticate, so we'll use another GitHub secret and store the cluster credentials in it.

There's a very neat 'one liner' command you can run to do this. It's taking the output of the `az aks get-credentials`
command we ran previously and storing the result as a secret called `CLUSTER_KUBECONFIG`. Run the following:

```bash
gh secret set CLUSTER_KUBECONFIG --body "$(az aks get-credentials --name $AKS_NAME --resource-group $RES_GROUP --file -)"
```

Next add a second job called `releaseJob` to the workflow YAML, beware the indentation, this should under the `jobs:`
key

<!-- {% raw %} -->

```yaml
releaseJob:
  name: "Release to Kubernetes"
  runs-on: ubuntu-latest
  if: ${{ github.ref == 'refs/heads/main' }}
  needs: buildJob

  steps:
    - name: "Configure kubeconfig"
      uses: azure/k8s-set-context@v4
      with:
        method: kubeconfig
        kubeconfig: ${{ secrets.CLUSTER_KUBECONFIG }}

    - name: "Sanity check Kubernetes"
      run: kubectl get nodes
```

<!-- {% endraw %} -->

This is doing a bunch of things so lets step through it:

- This second job has a dependency on the previous build job, obviously we don't want to run a release & deployment if
  the build has failed or hasn't finished!
- This job will only run if the code is in the `main` branch, which means we won't run deployments on pull requests,
  this is a common practice, but your release strategy may differ.
- It uses the `azure/k8s-set-context` action and the `CLUSTER_KUBECONFIG` secret to authenticate and point to our AKS
  cluster.
- We run a simple `kubectl` command to sanity check we are connected ok.

Save the file, commit and push to main just as before, and check the status using the GitHub actions page.

## 🪖 Deploy using Helm

Nearly there! Now we want to run `helm` in order to deploy the NanoMon app into the cluster, but also make sure it
deploys from the images we just built and pushed. As we saw in the previous sections on Helm, we can

Add the following two steps to the releaseJob (beware indentation again!)

<!-- {% raw %} -->

```yaml
- name: "Add Helm repo for Nanomon"
  run: |
    helm repo add nanomon 'https://raw.githubusercontent.com/benc-uk/nanomon/main/deploy/helm'
    helm repo update nanomon

- name: "Release app with Helm"
  run: |
    helm upgrade ci nanomon/nanomon --install --wait --timeout 120s \
    --set image.regRepo=${{ env.IMAGE_REG }} \
    --set image.tag=${{ env.IMAGE_TAG }} \
    --set ingress.enabled=true
```

<!-- {% endraw %} -->

The `helm upgrade` command is doing a lot, so let's break it down:

- `helm upgrade` tells Helm to upgrade an existing release, as we also pass `--install` this means Helm will install it
  first if it doesn't exist. Think of it as create and/or update.
- The release name is `ci` but could be anything you wish, it will be used to prefix all the resources in Kubernetes.
- The chart is referenced by the repo name and chart name, in this case it's a remote chart repository, but it could
  also be a local path.
- The `--set` flags pass parameters into the chart for this release, which are the ACR name, plus the image tag string.
  These are available as variables in our workflow `IMAGE_REG` and `IMAGE_TAG` which we set earlier.
- We also enable the ingress, as we want to be able to access the app externally.
- The `--wait --timeout 120s` flags tell Helm to wait for the pods to be running before considering the deployment
  successful, with a timeout of 120 seconds.

As you can see Helm is a powerful way to deploy apps to Kubernetes, sometimes with a single command

Once again save, commit and push, then check the status of the workflow. It's likely you made a mistake, keep committing
& pushing to fix and re-run the workflow until it completes and runs green.

You can validate the deployment with the usual `kubectl get pods` command and `helm ls` to view the Helm release.
Hopefully all the pods should be running.

## 🏅 Bonus - Environments

GitHub has the concept of
[environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment),
which are an abstraction representing a target set of resources or a deployed application. This lets you use the GitHub
UI to see the status of deployments targeting that environment, and even give users a link to access it

We can add an environment simply by adding the follow bit of YAML under the `releaseJob` job:

```yaml
environment:
  name: workshop-environment
  url: http://__PUBLIC_IP_OF_INGRESS__/
```

Tip. The `environment` part needs to line up with the `needs` and `if` parts in the job YAML.

The `name` can be anything you wish and the URL needs to point to the public IP address of your ingress controller which
you were referencing earlier, if you've forgotten it try running  
`kubectl get svc -A | grep LoadBalancer | awk '{print $5}'`

## 🏆 Extra Mega Bonus - Validation of the Deployment

You can add a final step to the `releaseJob` to validate the deployment, by using some bash voodoo & `curl` to hit the
public IP address of the ingress controller, and call the status endpoint of the app, in JSON that is returned check for
the version to match the version we just deployed.

> 📝 NOTE: This is only possible because NanoMon was written in such a way it allows for the version to be injected at
> build time, and that it also exposes via the API at runtime. Something to think about when writing your own systems

<!-- {% raw %} -->

```yaml
- name: "Validate deployment"
  run: |
    sleep 10
    while ! curl -s http://__PUBLIC_IP_OF_INGRESS__/api/status | grep "version\":\"${{ env.VERSION }}"; do sleep 5; done
  timeout-minutes: 2
```

<!-- {% endraw %} -->

## 🎉 Conclusion

OK that's it for this optional section, if you're not a fan of DevOps, then you probably hated that, but otherwise
hopefully you found it useful! We're done with the workshop now, so feel free to go back to the main index and explore
any of the other sections you may have missed.

## Navigation

[Return to Main Index 🏠](../readme.md) ‖ [Previous Section ⏪](../11-gitops-flux/readme.md)
