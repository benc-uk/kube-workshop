#!/usr/bin/env bash
# Teardown - delete the Azure resource group created by this e2e test.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh

echo "This will DELETE resource group '${RES_GROUP}' (subscription ${SUBSCRIPTION_ID}) and EVERYTHING in it."
if [[ "${1:-}" != "--yes" ]]; then
  echo
  echo "Dry run. Re-run with --yes to actually delete:"
  echo "  ./90-teardown.sh --yes"
  exit 0
fi

az account set --subscription "${SUBSCRIPTION_ID}"
echo "==> Deleting resource group ${RES_GROUP} (async, returns immediately)"
az group delete --name "${RES_GROUP}" --yes --no-wait
echo "==> Delete initiated."
echo "    Local state (.acr_name, rendered/) left intact; delete them for a fresh ACR name next run."
