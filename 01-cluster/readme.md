# 🚦 Deploy Kubernetes

Deploying AKS and Kubernetes can be extremely complex, however for the purposes of this workshop, a default and basic cluster can be deployed very quickly.

## 🚀 AKS Cluster Deployment

The following commands can be used to quickly deploy the cluster

```bash
# Create resource group
az group create --name $RES_GROUP --location $REGION

# Create cluster
az aks create --resource-group $RES_GROUP \
--name $AKS_NAME \
--location $REGION \
--node-count 2 --node-vm-size Standard_B2ms \
--kubernetes-version 1.22.4 \
--verbose
```

This creates a cluster with the following characteristics:
- Two small B-Series nodes in a single node pool
- Basic 'Kubenet' networking (Azure CNI is not required). [See docs if you wish to learn more](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-network)
- Local cluster admin account, but RBAC enabled.
- No addons enabled, e.g. monitoring, AAD integration, auto-scaling, GitOps etc

The `az aks create` command has [MANY options](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create) for example, you many wish to skip the use of SSH keys with `--no-ssh-key` as they won't be needed.  
Additionally you may wish to change the size or number of nodes, this clearly has cost implications.

## 🔌 Connect to the cluster

To enable kubectl (and other tools) to access the cluster:

```bash
az aks get-credentials --name $AKS_NAME --resource-group $RES_GROUP
```

Now you can run some simple `kubectl` commands

```bash
# Get all nodes in the cluster
kubectl get nodes

# Get all pods in the cluster
kubectl get pods --all-namespaces
```