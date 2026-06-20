#!/usr/bin/env bash
# Section 0 - Preflight: verify tooling, Azure login and target subscription.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh

echo "==> Checking required tools"
command -v az >/dev/null 2>&1 || { echo "ERROR: Azure CLI (az) not found. Install: https://aka.ms/azure-cli"; exit 1; }
echo "  az      : $(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || echo present)"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "  kubectl : not found, installing via 'az aks install-cli'"
  az aks install-cli
fi
echo "  kubectl : $(kubectl version --client -o yaml 2>/dev/null | grep -m1 gitVersion | awk '{print $2}' || echo present)"

echo "==> Checking Azure login"
if ! az account show >/dev/null 2>&1; then
  echo "  Not logged in, launching 'az login'"
  az login >/dev/null
fi

echo "==> Setting subscription"
az account set --subscription "${SUBSCRIPTION_ID}"
az account show -o table

echo "==> Preflight complete"
