# 👷 CI/CD with Kubernetes

This is an advanced optional section detailing how to set up a continuous integration (CI) and continuous deployment (CD) pipeline, which will deploy to Kubernetes using Helm.

There are many CI/CD offerings available, we will use GitHub Actions, as it's easy to set up and most developers will already have accounts.

> 📝 NOTE: This is not intended to be full guide or tutorial on GitHub Actions, you would be better off starting [here](https://docs.github.com/en/actions/learn-github-actions) or [here](https://docs.microsoft.com/en-us/learn/paths/automate-workflow-github-actions/?source=learn)

## Get Started with GitHub Actions

We'll use a fork of this repo in order to set things up, but in principle you could also start with an new/empty repo on GitHub.

- Go to the repo for this workshop [https://github.com/benc-uk/](https://github.com/benc-uk/)
- Fork the repo to your own personal GitHub account, by clicking the 'Fork' button near the top right.
- Clone the repo using git to your local machine.

Inside the `.github/workflows` directory, create a new file called `build-release.yaml` and paste in the contents:

> 📝 NOTE: This is special directory path used by GitHub Actions

```yaml
# Name of the workflow
name: CI Build & Release

# Triggers for running
on:
  workflow_dispatch: # This allows manually running from GitHub web UI
  push:
    branches: ["main"] # Standard CI trigger when main branch is pushed

# One job for building the app
jobs:
  buildJob:
    name: "Build & push images"
    runs-on: ubuntu-latest
    steps:
      # Checkout code from another repo on GitHub
      - name: "Checkout app code repo"
        uses: actions/checkout@v2
        with:
          repository: benc-uk/smilr
```

The comments in the file should hopefully explain what is happening. The name and filename do not reflect the current function, but the intent of what we are building towards.

Now commit the changes and push to the main branch, yes this is not a typical way of working, but adding a code review or PR process would merely distract from what we are doing.

The best place to check the status is from the GitHub web site and in the 'Actions' within your forked repo, e.g. [https://github.com/{your-github-user}/kube-workshop/actions](https://github.com/{your-github-user}/kube-workshop/actions)

###

Install the GitHub CLI, this will make setting up the secrets a lot more simple.

- On MacOS: https://github.com/cli/cli#macos
- On Ubuntu/WSL: `curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/kubectl.sh | bash`

```bash
gh secret set ACR_PASSWORD --body "$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)"
```

```bash
gh secret set CLUSTER_KUBECONFIG --body "$(az aks get-credentials -g $RES_GROUP -n $AKS_NAME --file -)"
```

```bash
az acr repository show-tags --name $ACR_NAME --repository smilr/data-api
```
