#!/usr/bin/env bash
# Section 4 - Deploy the backend: PostgreSQL then the API.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh

mkdir -p rendered

echo "==> Rendering postgres-deployment.yaml (__ACR_NAME__ -> ${ACR_NAME})"
sed "s/__ACR_NAME__/${ACR_NAME}/g" \
  "${MANIFEST_SRC}/postgres-deployment.yaml" >rendered/postgres-deployment.yaml

echo "==> Applying PostgreSQL deployment"
kubectl apply -f rendered/postgres-deployment.yaml

echo "==> Waiting for PostgreSQL pod to be Ready"
kubectl wait --for=condition=Ready pod --selector app=postgres --timeout=180s

echo "==> Getting PostgreSQL pod IP"
POSTGRES_POD_IP="$(kubectl get pod --selector app=postgres -o jsonpath='{.items[0].status.podIP}')"
echo "  POSTGRES_POD_IP = ${POSTGRES_POD_IP}"
if [[ -z "${POSTGRES_POD_IP}" ]]; then
  echo "ERROR: could not determine postgres pod IP"; exit 1
fi

echo "==> Rendering api-deployment.yaml (__ACR_NAME__, __POSTGRES_POD_IP__, add port=5432)"
sed -e "s/__ACR_NAME__/${ACR_NAME}/g" \
    -e "s/__POSTGRES_POD_IP__/${POSTGRES_POD_IP}/g" \
    -e "s/host=${POSTGRES_POD_IP} user=/host=${POSTGRES_POD_IP} port=5432 user=/g" \
    "${MANIFEST_SRC}/api-deployment.yaml" >rendered/api-deployment.yaml

echo "==> Applying API deployment"
kubectl apply -f rendered/api-deployment.yaml

echo "==> Waiting for API pods to be Ready"
kubectl wait --for=condition=Ready pod --selector app=nanomon-api --timeout=180s

echo "==> Current state"
kubectl get deploy,pod -o wide

echo "==> Smoke-testing the API via port-forward"
API_POD="$(kubectl get pod --selector app=nanomon-api -o jsonpath='{.items[0].metadata.name}')"
kubectl port-forward "${API_POD}" 8000:8000 >/tmp/ws1-pf.log 2>&1 &
PF_PID=$!
# give the tunnel a moment to establish
for i in {1..10}; do
  sleep 1
  if curl -fsS http://localhost:8000/api/info >/dev/null 2>&1; then break; fi
done
echo "  /api/info:"
curl -fsS http://localhost:8000/api/info || echo "  (info endpoint not reachable)"
echo
echo "  /api/status:"
curl -fsS http://localhost:8000/api/status || echo "  (status endpoint not reachable)"
echo
kill "${PF_PID}" >/dev/null 2>&1 || true

echo "==> Section 4 complete"
