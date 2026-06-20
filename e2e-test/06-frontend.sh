#!/usr/bin/env bash
# Section 6 - Add the frontend (Deployment + LoadBalancer Service).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh
mkdir -p rendered
SRC="${REPO_ROOT}/content/06-frontend"

echo "==> Resolving API external IP from 'api' service"
API_IP="$(kubectl get svc api -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
[[ -z "${API_IP}" ]] && { echo "ERROR: API external IP not found, run 05-network.sh first"; exit 1; }
echo "  API external IP: ${API_IP}"

echo "==> Rendering & applying frontend deployment (__ACR_NAME__, __API_EXTERNAL_IP__)"
sed -e "s/__ACR_NAME__/${ACR_NAME}/g" \
    -e "s/__API_EXTERNAL_IP__/${API_IP}/g" \
    "${SRC}/frontend-deployment.yaml" >rendered/06-frontend-deployment.yaml
kubectl apply -f rendered/06-frontend-deployment.yaml

echo "==> Applying frontend LoadBalancer service"
kubectl apply -f "${SRC}/frontend-service.yaml"

echo "==> Waiting for frontend rollout"
kubectl rollout status deployment/nanomon-frontend --timeout=180s

echo "==> Waiting for frontend service external IP"
FE_IP=""
for _ in $(seq 1 60); do
  FE_IP="$(kubectl get svc frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  [[ -n "${FE_IP}" ]] && break
  sleep 5
done
echo "  Frontend external IP: ${FE_IP:-<none>}"
[[ -z "${FE_IP}" ]] && { echo "ERROR: frontend external IP not assigned"; exit 1; }

echo "==> Testing http://${FE_IP}/"
curl -fsS --max-time 20 -o /dev/null -w "  HTTP %{http_code}\n" "http://${FE_IP}/" || echo "  (not reachable yet)"
echo "==> Frontend available at: http://${FE_IP}/"
echo "==> Section 6 complete"
