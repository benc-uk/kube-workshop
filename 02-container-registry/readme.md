# 📦 Container Registry & Images

We will deploy & use a private registry to hold the application container images. This is not strictly necessary as we could pull the images from a public repo, however using a private repo is a more realistic approach.

[Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/) will be set up and used.

## 🚀 ACR Deployment

Deploying ACR is very simple:

```bash
az acr create --name $ACR_NAME --resource-group $RES_GROUP \
--sku Standard \
--admin-enabled true
```

## 📥 Import images

For the sake of speed and maintaining the focus on Kubernetes we will import pre-built images from another registry (GitHub Container Registry), rather than build them from source.

We will cover what the application does and what these containers are for in the next section, for now we can just import them.

To do so we use the `az acr import` command:

```bash
# Import application frontend container image
az acr import --name $ACR_NAME --resource-group $RES_GROUP \
--source ghcr.io/benc-uk/smilr/frontend:latest \
--image smilr/frontend:latest

# Import application data API container image
az acr import --name $ACR_NAME --resource-group $RES_GROUP \
--source ghcr.io/benc-uk/smilr/data-api:latest \
--image smilr/data-api:latest
```

If you wish to check and see imported images, you can go over to the ACR resource in the Azure portal, and into the 'Repositories' section.

## 🔌 Connect AKS to ACR

Kuberenetes requires a way to authenticate and access images stored in private registries. There are a number of ways to enable Kubernetes to pull images from a private registry, however AKS provides a simple way to configure this through the Azure CLI.

```bash
az aks update --name $AKS_NAME --resource-group $RES_GROUP \
--attach-acr $ACR_NAME
```

Essentially this command is just assigning the "ACR Pull" role in Azure IAM to the managed identity used by AKS, on the ACR resource. 