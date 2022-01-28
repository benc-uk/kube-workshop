# 🧬 GitOps & Flux

This is an advanced and highly optional section going into two topics; Kustomize and also GitOps, using FluxCD.

## 🪓 Kustomize

This section provides a very brief intro to using [Kustomize](https://kustomize.io/)

Kustomize traverses a Kubernetes manifests to add, remove or update configuration options. It is available both as a standalone binary and as a native feature of kubectl.

Kustomize works by looking for `kustomization.yaml` files and operating on their contents.

[These slides provide a fairly good introduction](https://speakerdeck.com/spesnova/introduction-to-kustomize)

To demonstrate this in practice, create a new directory called `base`

Place the the following two files into it

<details>
<summary>Contents of base/deployment.yaml</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver
spec:
  selector:
    matchLabels:
      app: webserver
  template:
    metadata:
      labels:
        app: webserver
    spec:
      containers:
        - name: webserver
          image: nginx
          resources:
            limits:
              memory: "128Mi"
              cpu: "500m"
          ports:
            - containerPort: 80
```

</details>

<details>
<summary>Contents of base/kustomization.yaml</summary>

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
```

</details>

Now run kustomize via kubectl, as follows:

```bash
kubectl kustomize ./base
```

You will see the YAML printed to stdout, as we've not provided any changes in the `kustomization.yaml` all we get is a 1:1 version of the `deployment.yaml` file. This isn't very useful!

To understand what Kustomize can do. create a second directory at the same level as `base` called `overlay`

<details>
<summary>Contents of overlay/override.yaml</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webserver

spec:
  template:
    spec:
      containers:
        - name: webserver
          resources:
            limits:
              cpu: 330m
          env:
            - name: SOME_ENV_VAR
              value: Hello!
```

</details>

<details>
<summary>Contents of overlay/kustomization.yaml</summary>

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

# Reference to a base kustomization directory
resources:
  - ../base

# You can add suffixes and prefixes
nameSuffix: -dev

# Modify the image name or tags
images:
  - name: nginx
    newTag: 1.21-alpine

# Apply patches to override and set other values
patches:
  - ./override.yaml
```

</details>

The overlay/kustomization.yaml file is doing the following:

- Adding a suffix to the names of resources
- Changing the image tag to reference a specific tag
- Applying a patch file, with further modifications, such as changing the resource limits and adding an extra environmental variable.

See the [reference docs](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/) for all the options available in the kustomization.yaml file

The file & directory structure should look as follows:

```text
.
├── base
│   ├── deployment.yaml
│   └── kustomization.yaml
└── overlay
    ├── kustomization.yaml
    └── override.yaml
```

> 📝 NOTE: The names "base" and "overlay" are not special, often "environments" is used instead of "overlay", with sub-directories for each environment

Now running:

```bash
kubectl kustomize ./overlay
```

You will now see the overrides and modifications from the overlay applied to the base resources. With the modified nginx image tag, different resource limits and additional env var.

This could be applied to the cluster with the following command `kubectl -k ./overlay apply` however you don't need to do this.

## GitOps & Flux

GitOps is a methodology where you declaratively describe the entire desired state of your system using git. This includes the apps, config, dashboards, monitoring and everything else. This means you can use git branching and PR processes to enforce control of releases and provide traceability and transparency.

![gitops](./gitops.png)

Kubernetes doesn't support this concept out of the box, it requires special controllers to be deployed and manage this process. These controllers run inside the cluster, monitor the your git repositories for changes and then make the required updates to the state of the cluster, through a process called reconciliation.

We will use the [popular project FluxCD](https://fluxcd.io/) (also just called Flux or Flux v2), however other projects are available such as ArgoCD and support from GitLab

As GitOps is a "pull" vs "push" approach, it also allows you to lock down your Kubernetes cluster, and prevent developers and admins making direct changes with kubectl.

> NOTE: GitOps is a methodology and an approach, it is not the name of a product

### 💽 Install Flux CLI

[Flux is available as an AKS Extension](https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2) which is intended to simplify installing Flux into your cluster. However it requires

```bash
# My installer script
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/flux.sh | bash

# Or official one (needs sudo)
curl -s https://fluxcd.io/install.sh | sudo bash
```

### 🥾 Bootstrap Flux Into Cluster

[Generate a GitHub personal access token](https://github.com/settings/tokens) (PAT) that can create repositories by checking all permissions under "repo", copy the token and set it into an environmental variable called `GITHUB_TOKEN`

```bash
export GITHUB_TOKEN={NEW_TOKEN_VALUE}
```

Now fork this repo [github.com/benc-uk/kube-workshop](https://github.com/benc-uk/kube-workshop) to your own GitHub personal account.

Run the Flux bootstrap which should point to your fork by setting the owner parameter to your GitHub username:

```bash
flux bootstrap github \
  --owner=__CHANGE_ME__ \
  --repository=kube-workshop \
  --path=gitops/apps \
  --branch=main \
  --personal
```

Check the status of Flux with the following commands:

```bash
kubectl get kustomizations -A

kubectl get gitrepo -A

kubectl get pod -n flux-system
```

You should also see a new namespace called "hello-world", check with `kubectl get ns` this has been created by the `gitops/apps/hello-world.yaml` file in the repo and automatically applied by Flux

### 🚀 Deploying Resources

Clone the kube-workshop repo you forked earlier and open the directory in VS Code or other editor.

If you recall from the bootstrap command earlier we gave Flux a path within the repo to use and look for configurations, which was `gitops/apps` directory. The contents of the whole of the gitops directory is shown here.

```text
gitops
  ├── apps
  │   └── hello-world.yaml
  ├── base
  │   ├── data-api
  │   │   ├── deployment.yaml
  │   │   ├── kustomization.yaml
  │   │   └── service.yaml
  │   ├── frontend
  │   │   ├── deployment.yaml
  │   │   ├── ingress.yaml
  │   │   ├── kustomization.yaml
  │   │   └── service.yaml
  │   └── mongodb
  │       ├── kustomization.yaml
  │       └── mongo-statefulset.yaml
  └── disabled
      ├── mongodb
      │   ├── kustomization.yaml
      │   └── overrides.yaml
      └── smilr
          └── kustomization.yaml
```

The base directory provides us a library of Kustomization based resources we can use, but as it's outside of the `gitops/apps` path they will not be picked up by Flux.

⚠️ **STOP!** Before we proceed, ensure the `mongo-creds` Secret from the previous sections is still in the default namespace. If you have deleted it, [hope back to section 7 and quickly create it again. It's just a single command](../07-improvements/readme.md). Creating Secrets using the GitOps approach is problematic, as they need to be committed into a code repo. Flux supports solutions such as using [SOPS](https://fluxcd.io/docs/guides/mozilla-sops/) and [Sealed Secrets](https://fluxcd.io/docs/guides/sealed-secrets/) but for an intro such as this, they require too much extra setup, so we will skip over them.

First let's deploy MongoDB using Flux:

- Copy the `monogodb/` directory from "disabled" to "apps".
  - Note the `kustomization.yaml` in here is pointing at the base directory `../../base/mongodb` and overlaying it.
- Git commit these changes to the main branch and push up to GitHub.
- Wait for ~1 minute for Flux to rescan the git repo.
- Check for any errors with `kubectl get kustomizations -A`
- Check the default namespace for the new MongoDB StatefulSet and Pod using `kubectl get sts,pods -n default`

Next deploy the Smilr app:

- Copy the `smilr/` directory from "disabled" to "apps".
  - Note the `kustomization.yaml` in here is pointing at **several** base directories, for the app data-api and frontend.
- Edit the ACR name in the `gitops/apps/smilr/kustomization.yaml` file.
- Git commit these changes to the main branch and push up to GitHub.
- Wait for ~1 minute for Flux to rescan the git repo.
- Check for any errors with `kubectl get kustomizations -A`
- Check the default namespace for the new resources using `kubectl get deploy,pods,ingress -n default`

If you encounter problems or want to force the reconciliation you can use the `flux` CLI, e.g. `flux reconcile source git flux-system`

If we wanted to deploy this app across multiple environments or multiple times, we could create sub-directories under `apps/`, each containing different Kustomizations and modifying the deployment to suit that environment.
