# Super Bonus Section - GitOps & Flux

Work in progress

## Install flux CLI

```bash
# My installer
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/flux.sh | bash

# Or official one
curl -s https://fluxcd.io/install.sh | sudo bash
```

## Bootstrap into cluster

Generate a personal access token (PAT) that can create repositories by checking all permissions under repo. If a pre-existing repository is to be used the PAT’s user will require admin permissions on the repository in order to create a deploy key.

Export your GitHub personal access token as an environment variable:

```bash
export GITHUB_TOKEN=<your-token>
```

Run the bootstrap for a repository on your personal GitHub account:

```bash
flux bootstrap github \
  --owner=__CHANGE_ME__ \
  --repository=kube-workshop \
  --path=gitops/apps \
  --branch=main \
  --personal
```

Check

```bash
k get kustomizations -A

k get gitrepo -A

k get pod -n flux-system
```
