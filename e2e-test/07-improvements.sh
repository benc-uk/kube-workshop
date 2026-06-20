#!/usr/bin/env bash
# Section 7 - Production readiness: resource limits, readiness probes, Secret.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh
mkdir -p rendered
SRC="${REPO_ROOT}/content/07-improvements"

echo "==> Creating/updating database-creds secret (idempotent)"
kubectl create secret generic database-creds \
  --from-literal password='kindaSecret123!' \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Resolving API external IP (needed by the frontend manifest)"
API_IP="$(kubectl get svc api -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
[[ -z "${API_IP}" ]] && { echo "ERROR: API external IP not found, run earlier sections first"; exit 1; }
echo "  API external IP: ${API_IP}"

echo "==> Rendering improved manifests (resources, probes, secretKeyRef)"
sed "s/__ACR_NAME__/${ACR_NAME}/g" "${SRC}/postgres-deployment.yaml" >rendered/07-postgres-deployment.yaml
sed "s/__ACR_NAME__/${ACR_NAME}/g" "${SRC}/api-deployment.yaml" >rendered/07-api-deployment.yaml
sed -e "s/__ACR_NAME__/${ACR_NAME}/g" -e "s/__API_EXTERNAL_IP__/${API_IP}/g" \
    "${SRC}/frontend-deployment.yaml" >rendered/07-frontend-deployment.yaml

echo "==> Applying improved deployments"
kubectl apply -f rendered/07-postgres-deployment.yaml
kubectl apply -f rendered/07-api-deployment.yaml
kubectl apply -f rendered/07-frontend-deployment.yaml

echo "==> Waiting for rollouts"
kubectl rollout status deployment/postgres --timeout=180s
kubectl rollout status deployment/nanomon-api --timeout=180s
kubectl rollout status deployment/nanomon-frontend --timeout=180s

echo "==> Final state"
kubectl get deploy,svc,secret

echo "==> Verifying API health via external IP"
curl -fsS --max-time 20 "http://${API_IP}/api/status" && echo
echo "==> Section 7 complete"
