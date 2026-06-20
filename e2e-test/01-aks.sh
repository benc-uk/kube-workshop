#!/usr/bin/env bash
# Section 1 - Deploy AKS cluster.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh

echo "==> Ensuring resource providers are registered"
az provider register --namespace Microsoft.ContainerService >/dev/null 2>&1 || true

echo "==> Creating resource group ${RES_GROUP} in ${REGION}"
az group create --name "${RES_GROUP}" --location "${REGION}" -o table

echo "==> Querying latest supported Kubernetes version in ${REGION}"
KUBE_VERSION="$(az aks get-versions --location "${REGION}" -o json --query 'values[*].version | max(@)' -o tsv)"
echo "  Using Kubernetes version: ${KUBE_VERSION}"

if az aks show --resource-group "${RES_GROUP}" --name "${AKS_NAME}" >/dev/null 2>&1; then
  echo "==> AKS cluster ${AKS_NAME} already exists, skipping create"
else
  echo "==> Creating AKS cluster ${AKS_NAME} (this takes ~5 min)"
  if ! az aks create --resource-group "${RES_GROUP}" \
      --name "${AKS_NAME}" \
      --location "${REGION}" \
      --node-count "${NODE_COUNT}" --node-vm-size "${NODE_VM_SIZE}" \
      --kubernetes-version "${KUBE_VERSION}" \
      --no-ssh-key; then
    echo "==> Primary VM size ${NODE_VM_SIZE} failed, retrying with ${NODE_VM_SIZE_FALLBACK}"
    az aks create --resource-group "${RES_GROUP}" \
      --name "${AKS_NAME}" \
      --location "${REGION}" \
      --node-count "${NODE_COUNT}" --node-vm-size "${NODE_VM_SIZE_FALLBACK}" \
      --kubernetes-version "${KUBE_VERSION}" \
      --no-ssh-key
  fi
fi

echo "==> Fetching cluster credentials"
az aks get-credentials --name "${AKS_NAME}" --resource-group "${RES_GROUP}" --overwrite-existing

echo "==> Cluster nodes"
kubectl get nodes
echo "==> Section 1 complete"
