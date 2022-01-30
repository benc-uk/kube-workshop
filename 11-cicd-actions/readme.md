# Temporary

## Simple

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

```bash
#az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv
gh secret set ACR_PASSWORD --body "$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)"
```

```bash
gh secret set CLUSTER_KUBECONFIG --body "$(az aks get-credentials -g $RES_GROUP -n $AKS_NAME --file -)"
```

```bash
az acr repository show-tags --name $ACR_NAME --repository smilr/data-api
```
