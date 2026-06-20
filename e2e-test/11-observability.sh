#!/usr/bin/env bash
# Section 11 - Observability: install kube-prometheus-stack and verify Prometheus + Grafana.
# The dashboard exploration is browser-only; here we prove the stack works via API calls.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh

echo "==> Adding/updating the prometheus-community Helm repo"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update prometheus-community >/dev/null

echo "==> Ensuring 'monitoring' namespace exists"
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

echo "==> Installing/upgrading kube-prometheus-stack (release kube-mon)"
helm upgrade --install kube-mon prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=workshopAdmin \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --wait --timeout 10m

echo "==> Waiting for the operator-created Prometheus & Alertmanager pods"
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=prometheus -n monitoring --timeout=300s || true
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=alertmanager -n monitoring --timeout=300s || true

echo "==> Monitoring stack pods:"
kubectl get pods -n monitoring

# Resolve service names dynamically (release-name prefix is truncated in the chart)
PROM_SVC="$(kubectl get svc -n monitoring --no-headers -o custom-columns=:.metadata.name | grep -E 'prometheus$' | grep -v operator | head -1)"
GRAF_SVC="$(kubectl get svc -n monitoring --no-headers -o custom-columns=:.metadata.name | grep -E 'grafana$' | head -1)"
echo "  Prometheus service: ${PROM_SVC}"
echo "  Grafana service:    ${GRAF_SVC}"

echo "==> Verifying Prometheus via a PromQL query (running pods per namespace)"
kubectl port-forward -n monitoring "svc/${PROM_SVC}" 9090:9090 >/tmp/ws1-prom-pf.log 2>&1 &
PF_PROM=$!
sleep 5
curl -fsS --max-time 15 --data-urlencode 'query=count by (namespace) (kube_pod_status_phase{phase="Running"})' \
  http://localhost:9090/api/v1/query | head -c 600 || echo "  (prometheus query failed)"
echo
kill "${PF_PROM}" >/dev/null 2>&1 || true

echo "==> Verifying Grafana health endpoint"
kubectl port-forward -n monitoring "svc/${GRAF_SVC}" 3000:80 >/tmp/ws1-graf-pf.log 2>&1 &
PF_GRAF=$!
sleep 5
curl -fsS --max-time 15 http://localhost:3000/api/health || echo "  (grafana health failed)"
echo
kill "${PF_GRAF}" >/dev/null 2>&1 || true

echo "==> Section 11 complete"
echo "  Grafana login: admin / workshopAdmin (port-forward svc/${GRAF_SVC} 3000:80)"
echo "  Prometheus UI: port-forward svc/${PROM_SVC} 9090:9090"
