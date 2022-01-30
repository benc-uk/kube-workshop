```bash
#az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv
gh secret set ACR_PASSWORD --body "$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)"
```
