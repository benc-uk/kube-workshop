#!/usr/bin/env bash
# Run the full chain: preflight -> AKS -> ACR -> backend (sections 0,1,2,4).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

./00-preflight.sh
./01-aks.sh
./02-acr.sh
./04-deploy.sh
./05-network.sh
./06-frontend.sh
./07-improvements.sh
./08-more-improvements.sh
./09a-gateway.sh

echo
echo "==================================================="
echo " All sections (0-8 + 9a Gateway API) completed."
echo "==================================================="
