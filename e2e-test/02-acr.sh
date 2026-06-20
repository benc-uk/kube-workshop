#!/usr/bin/env bash
# Section 2 - Container registry: create ACR, import images, attach to AKS.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh

echo "==> Ensuring resource provider is registered"
az provider register --namespace Microsoft.ContainerRegistry >/dev/null 2>&1 || true

if az acr show --name "${ACR_NAME}" >/dev/null 2>&1; then
  echo "==> ACR ${ACR_NAME} already exists, skipping create"
else
  echo "==> Creating ACR ${ACR_NAME}"
  az acr create --name "${ACR_NAME}" --resource-group "${RES_GROUP}" --sku Standard -o table
fi

echo "==> Importing application images"
images=(
  "nanomon-frontend"
  "nanomon-api"
  "nanomon-runner"
  "nanomon-postgres"
)
for img in "${images[@]}"; do
  if az acr repository show --name "${ACR_NAME}" --image "${img}:latest" >/dev/null 2>&1; then
    echo "  ${img}: already present, skipping"
  else
    echo "  ${img}: importing"
    az acr import --name "${ACR_NAME}" --resource-group "${RES_GROUP}" \
      --source "ghcr.io/benc-uk/${img}:latest" \
      --image "${img}:latest"
  fi
done

echo "==> Imported repositories:"
az acr repository list --name "${ACR_NAME}" -o table

echo "==> Attaching ACR to AKS (assigns AcrPull role)"
az aks update --name "${AKS_NAME}" --resource-group "${RES_GROUP}" --attach-acr "${ACR_NAME}" -o none
echo "==> Section 2 complete"
