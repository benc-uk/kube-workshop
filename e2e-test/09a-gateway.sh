#!/usr/bin/env bash
# Section 9a - Helm & Gateway API: NGINX Gateway Fabric, Gateway + HTTPRoute.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh
mkdir -p rendered
SRC="${REPO_ROOT}/content/09a-helm-gateway-api"
GW_API_VERSION="v1.4.1"

echo "==> Installing Gateway API CRDs (${GW_API_VERSION}, standard channel)"
kubectl apply --server-side -f \
  "https://github.com/kubernetes-sigs/gateway-api/releases/download/${GW_API_VERSION}/standard-install.yaml"

echo "==> Ensuring 'nginx-gateway' namespace exists"
kubectl create namespace nginx-gateway --dry-run=client -o yaml | kubectl apply -f -

echo "==> Installing/upgrading NGINX Gateway Fabric (helm release ngf)"
helm upgrade --install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --namespace nginx-gateway --wait --timeout 5m

echo "==> Applying the Gateway resource (in nginx-gateway namespace)"
kubectl apply -f "${SRC}/gateway.yaml" -n nginx-gateway

echo "==> Waiting for gateway service external IP"
GW_IP=""
for _ in $(seq 1 60); do
  GW_IP="$(kubectl get svc nanomon-gateway-nginx -n nginx-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  [[ -n "${GW_IP}" ]] && break
  sleep 5
done
echo "  Gateway external IP: ${GW_IP:-<none>}"
[[ -z "${GW_IP}" ]] && { echo "ERROR: gateway external IP not assigned"; exit 1; }

echo "==> Switching API & frontend services to ClusterIP on container ports (8000 / 8001)"
kubectl apply -f "${SRC}/api-service.yaml"
kubectl apply -f "${SRC}/frontend-service.yaml"

echo "==> Ensuring frontend uses same-origin /api"
sed "s/__ACR_NAME__/${ACR_NAME}/g" "${SRC}/frontend-deployment.yaml" >rendered/09a-frontend-deployment.yaml
kubectl apply -f rendered/09a-frontend-deployment.yaml
kubectl rollout status deployment/nanomon-frontend --timeout=180s

echo "==> Applying the HTTPRoute"
kubectl apply -f "${SRC}/http-route.yaml"

echo "==> Final state"
kubectl get gateway,httproute
echo "--- gateway namespace services ---"
kubectl get svc -n nginx-gateway
echo "--- app services ---"
kubectl get svc

echo "==> Testing through the gateway IP ${GW_IP}"
sleep 5
curl -fsS --max-time 20 -o /dev/null -w "  GET /  -> HTTP %{http_code}\n" "http://${GW_IP}/" || echo "  (frontend not reachable yet)"
echo "==> Section 9a complete - app served at http://${GW_IP}/"
