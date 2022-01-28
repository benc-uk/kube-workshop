# Super Bonus Section - GitOps & Flux

Work in progress

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

Create a second directory at the same level as `base` called `overlay`

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
patchesStrategicMerge:
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

## 💽 Install Flux CLI

```bash
# My installer script
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/flux.sh | bash

# Or official one (needs sudo)
curl -s https://fluxcd.io/install.sh | sudo bash
```

## 🥾 Bootstrap Flux Into Cluster

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

## Adding Resources
