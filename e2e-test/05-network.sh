#!/usr/bin/env bash
# Section 5 - Basic networking: Services for PostgreSQL and the API.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh
mkdir -p rendered
SRC="${REPO_ROOT}/content/05-network-basics"

echo "==> Applying PostgreSQL ClusterIP service (name: database)"
kubectl apply -f "${SRC}/postgres-service.yaml"

echo "==> Rendering & applying API deployment (DSN now targets host=database)"
sed "s/__ACR_NAME__/${ACR_NAME}/g" "${SRC}/api-deployment.yaml" >rendered/05-api-deployment.yaml
kubectl apply -f rendered/05-api-deployment.yaml

echo "==> Applying API LoadBalancer service"
kubectl apply -f "${SRC}/api-service.yaml"

echo "==> Waiting for API rollout"
kubectl rollout status deployment/nanomon-api --timeout=180s

echo "==> Waiting for API service external IP (can take a couple of minutes)"
API_IP=""
for _ in $(seq 1 60); do
  API_IP="$(kubectl get svc api -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  [[ -n "${API_IP}" ]] && break
  sleep 5
done
echo "  API external IP: ${API_IP:-<none>}"
[[ -z "${API_IP}" ]] && { echo "ERROR: API external IP not assigned"; exit 1; }

echo "==> Testing http://${API_IP}/api/status"
curl -fsS --max-time 20 "http://${API_IP}/api/status" || echo "  (not reachable yet, may need a few more seconds)"
echo
echo "==> Section 5 complete"
