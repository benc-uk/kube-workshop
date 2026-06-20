#!/usr/bin/env bash
# Section 10 - Scaling & Stateful workloads: manual scale, HPA, postgres StatefulSet + PVC.
# Skips the destructive "delete everything + helm install whole app" step (it uses Ingress,
# and we deliberately moved to the Gateway API in 9a).
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh
SRC="${REPO_ROOT}/content/10-extra-advanced"

echo "############################################################"
echo "# 1. Manual horizontal scaling of the API"
echo "############################################################"
kubectl scale deployment nanomon-api --replicas 4
kubectl rollout status deployment/nanomon-api --timeout=120s
kubectl get pods -l app=nanomon-api -o wide
echo "==> Scaling back to 2"
kubectl scale deployment nanomon-api --replicas 2

echo
echo "############################################################"
echo "# 2. Convert postgres Deployment -> StatefulSet with a PVC"
echo "############################################################"
echo "==> Deleting the postgres Deployment (data is ephemeral until now)"
kubectl delete deployment postgres --ignore-not-found
echo "==> Applying the StatefulSet (dynamic PVC on 'default' storage class)"
kubectl apply -f "${SRC}/postgres-statefulset.yaml"
echo "==> Waiting for postgres-0 to be Ready (PVC provisioning can take a minute)"
kubectl rollout status statefulset/postgres --timeout=300s
echo "==> PersistentVolume / PersistentVolumeClaim:"
kubectl get pv,pvc
echo "==> postgres init log (init script runs once on the fresh volume):"
kubectl logs -l app=postgres --tail=15 | grep -Ei 'nanomon_init|ready to accept' || true

echo
echo "############################################################"
echo "# 3. Horizontal Pod Autoscaler for the API"
echo "############################################################"
kubectl delete hpa nanomon-api --ignore-not-found
kubectl autoscale deployment nanomon-api --cpu-percent=50 --min=2 --max=10
kubectl get hpa nanomon-api

echo
echo "############################################################"
echo "# 4. (Best effort) generate load and watch the HPA react"
echo "############################################################"
GW_IP="$(kubectl get svc nanomon-gateway-nginx -n nginx-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
if [[ -z "${GW_IP}" ]]; then
  echo "  No gateway IP found, skipping load test."
else
  if [[ ! -x ./hey_linux_amd64 ]]; then
    echo "==> Downloading 'hey' load generator"
    wget -q https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 -O hey_linux_amd64 && chmod +x hey_linux_amd64 || echo "  (download failed)"
  fi
  if [[ -x ./hey_linux_amd64 ]]; then
    echo "==> Generating load for 120s against http://${GW_IP}/api/status (20 concurrent)"
    ./hey_linux_amd64 -z 120s -c 20 "http://${GW_IP}/api/status" >/dev/null 2>&1 || true
    echo "==> HPA status after load:"
    kubectl get hpa nanomon-api
    kubectl get pods -l app=nanomon-api
    echo "  (Pods scale back to min=2 ~5 min after load stops.)"
  fi
fi

echo
echo "==> Section 10 complete (skipped destructive whole-app Helm reinstall by design)"
