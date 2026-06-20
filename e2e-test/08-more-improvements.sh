#!/usr/bin/env bash
# Section 8 - ConfigMaps & Volumes: official postgres image + init SQL, plus the runner.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
source ./vars.sh
mkdir -p rendered
SRC="${REPO_ROOT}/content/08-more-improvements"

echo "==> Creating/updating nanomon-sql-init ConfigMap from nanomon_init.sql"
kubectl create configmap nanomon-sql-init \
  --from-file="${SRC}/nanomon_init.sql" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "==> Recreating postgres deployment (official postgres:17 + initdb volume)"
# Delete first so the new official image initialises a fresh data dir and runs the init script.
kubectl delete deployment postgres --ignore-not-found
kubectl apply -f "${SRC}/postgres-deployment.yaml"
kubectl rollout status deployment/postgres --timeout=180s

echo "==> Postgres init log (should show nanomon_init.sql executed)"
kubectl logs -l app=postgres --tail=40 | grep -Ei 'nanomon_init|database system is ready|CREATE' || true

echo "==> Rendering & applying the runner deployment"
sed "s/__ACR_NAME__/${ACR_NAME}/g" "${SRC}/runner-deployment.yaml" >rendered/08-runner-deployment.yaml
kubectl apply -f rendered/08-runner-deployment.yaml
kubectl rollout status deployment/nanomon-runner --timeout=180s

echo "==> Current state"
kubectl get deploy,pod,configmap

echo "==> Runner log (last few lines)"
kubectl logs -l app=nanomon-runner --tail=15 || true
echo "==> Section 8 complete"
