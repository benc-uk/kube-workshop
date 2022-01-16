# 🚦 Deploying Kubernetes

Deploying AKS and Kubernetes can be extremely complex, however for the purposes of this workshop, a default and basic cluster can be deployed very quickly.

## 🚀 AKS Cluster Deployment

The following commands can be used to quickly deploy an AKS cluster:

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

This should take 3~4 minutes, and creates a cluster with the following characteristics:

- Two small B-Series nodes in a single node pool.
- Basic 'Kubenet' networking (Azure CNI is not required for this workshop). [See docs if you wish to learn more](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-network)
- Local cluster admin account, but RBAC enabled.
- No other addons enabled, e.g. monitoring, AAD integration, auto-scaling, GitOps etc

The `az aks create` command has [MANY options](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-create) for example, you many wish to skip the use of SSH keys with `--no-ssh-key` as they won't be needed.  
Additionally you may wish to change the size or number of nodes, however this clearly has cost implications.

## 🔌 Connect to the Cluster

To enable kubectl (and other tools) to access the cluster, run the following:

```bash
az aks get-credentials --name $AKS_NAME --resource-group $RES_GROUP
```

This will create Kubernetes config file in your home directory `~/.kube/config` which is the default location, used by kubectl.  
Now you can run some simple `kubectl` commands to validate the health and status of your cluster:

```bash
# Get all nodes in the cluster
kubectl get nodes

# Get all pods in the cluster
kubectl get pods --all-namespaces
```

> 📝 NOTE: Don't be alarmed by all the pods you see running in the 'kube-system' namespace. These are deployed by default by AKS and perform management tasks we don't need to worry about. You can still consider your cluster "empty"

## ⏯️ Appendix - Stopping & Starting the cluster

If you are concerned about the costs for running the cluster you can stop and start it at any time. This essentially stops the node VMs in Azure, meaning the costs for the cluster are greatly reduced. 

```bash
# Stop the cluster
az aks stop --resource-group $RES_GROUP --name $AKS_NAME

# Start the cluster
az aks start --resource-group $RES_GROUP --name $AKS_NAME
```

> 📝 NOTE: Start and stop operations do take several minutes to complete, so typically you would perform them only at the start or end of the day.
