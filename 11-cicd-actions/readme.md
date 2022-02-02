# Temporary

👷 WORK IN PROGRESS

## Get Started with GitHub Actions

We'll use a fork of this repo in order to set things up, but in principlal you could also start with an empty :

- Got to the repo for this workshop [https://github.com/benc-uk/](https://github.com/benc-uk/)
- Fork the repo to your own personal GitHub account, by clicking the 'Fork' button near the top right.

```yaml
name: Hello World

on:
  # This lets us manually trigger the workflow from GitHub website
  workflow_dispatch:
  # This is a standard CI trigger based git push to a specific branch
  push:
    branches: ["main"]

# We can set variables
env:
  MESSAGE: Hello world!

# This is about the simplest single job & single step workflow possible
jobs:
  hello-world:
    runs-on: ubuntu-latest
    steps:
      - run: echo $MESSAGE
```

Create GitHub secrets,

```bash
gh secret set ACR_PASSWORD --body "$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)"
```

```bash
gh secret set CLUSTER_KUBECONFIG --body "$(az aks get-credentials -g $RES_GROUP -n $AKS_NAME --file -)"
```

```bash
az acr repository show-tags --name $ACR_NAME --repository smilr/data-api
```
