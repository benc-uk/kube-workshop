# Temporary

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
