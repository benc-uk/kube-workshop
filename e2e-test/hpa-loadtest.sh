#!/usr/bin/env bash
# Best-effort HPA load test using parallel curl (hey binary download is blocked).
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh >/dev/null

GW_IP="$(kubectl get svc nanomon-gateway-nginx -n nginx-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
[[ -z "${GW_IP}" ]] && { echo "No gateway IP, aborting"; exit 1; }

DURATION="${1:-150}"
WORKERS="${2:-40}"
echo "==> HPA before load:"
kubectl get hpa nanomon-api

echo "==> Generating load: ${WORKERS} workers x ${DURATION}s against http://${GW_IP}/api/status"
end=$((SECONDS + DURATION))
for _ in $(seq 1 "${WORKERS}"); do
  ( while [ "${SECONDS}" -lt "${end}" ]; do curl -s -o /dev/null --max-time 5 "http://${GW_IP}/api/status"; done ) &
done
wait

echo "==> HPA after load:"
kubectl get hpa nanomon-api
echo "==> API pods after load:"
kubectl get pods -l app=nanomon-api
echo "  (HPA scales back to min=2 a few minutes after load stops.)"
