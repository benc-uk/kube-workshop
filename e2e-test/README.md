# Kube Workshop - End-to-End Test

Automated, scripted run-through of the [kube-workshop](../readme.md) against a real Azure
Kubernetes Service (AKS) cluster. It stands up everything the workshop builds by hand, sections 0
through 9a, and includes the optional bonus sections 10 and 11.

The scripts render the workshop's own YAML manifests from `../content/**` (substituting the
`__PLACEHOLDER__` values) and apply them, so this doubles as a smoke test that the workshop
instructions still work end to end.

## What it deploys

The full NanoMon app on AKS: PostgreSQL, the data API, the frontend and the runner, fronted by the
Kubernetes Gateway API (NGINX Gateway Fabric). Everything lands in one Azure resource group.

## Prerequisites

- `az` (Azure CLI), logged in to a subscription where you have **Owner** (needed to attach ACR to AKS)
- `kubectl` and `helm`
- `bash`, `curl`, `openssl`
- `wget`/`curl` outbound access for Helm charts and container images

## Setup

```bash
cp vars.sh.sample vars.sh   # then edit vars.sh (or override values via the environment)
```

`vars.sh` is git-ignored, so your subscription id and names never get committed. Key settings:

| Variable          | Default              | Notes                                                 |
| ----------------- | -------------------- | ----------------------------------------------------- |
| `SUBSCRIPTION_ID` | current `az` context | Subscription to deploy into                           |
| `RES_GROUP`       | `kube-workshop-e2e`  | Resource group (created if missing)                   |
| `REGION`          | `northeurope`        | Azure region                                          |
| `AKS_NAME`        | `aks-kube-workshop`  | Cluster name                                          |
| `ACR_NAME`        | auto-generated       | Globally unique, persisted to `.acr_name`             |
| `NODE_VM_SIZE`    | `Standard_B2ms`      | Falls back to `NODE_VM_SIZE_FALLBACK` on quota errors |

## Usage

Run the whole main workshop (sections 0 to 9a):

```bash
./run-all.sh
```

Or run any step on its own (each is idempotent and re-runnable):

```bash
source vars.sh
./00-preflight.sh
./01-aks.sh
...
```

When it finishes, `09a-gateway.sh` prints the single public IP the app is served on
(`http://<gateway-ip>/`).

## Scripts

| Script                    | Workshop section | What it does                                                  |
| ------------------------- | ---------------- | ------------------------------------------------------------- |
| `vars.sh`                 | 0                | Shared config (copied from `vars.sh.sample`)                  |
| `00-preflight.sh`         | 0                | Checks tools, `az login`, sets the subscription               |
| `01-aks.sh`               | 1                | Resource group + AKS cluster (auto-picks latest k8s version)  |
| `02-acr.sh`               | 2                | ACR, imports the 4 NanoMon images, attaches ACR to AKS        |
| `04-deploy.sh`            | 4                | Deploys PostgreSQL + API                                      |
| `05-network.sh`           | 5                | `database` service, exposes the API via LoadBalancer          |
| `06-frontend.sh`          | 6                | Deploys + exposes the frontend                                |
| `07-improvements.sh`      | 7                | Resource limits, readiness probes, DB password Secret         |
| `08-more-improvements.sh` | 8                | SQL init ConfigMap, official `postgres:17`, the runner        |
| `09a-gateway.sh`          | 9a               | Gateway API CRDs + NGINX Gateway Fabric, Gateway + HTTPRoute  |
| `run-all.sh`              | 0-9a             | Runs the above in order, stops on first failure               |
| `10-scaling-stateful.sh`  | 10 (bonus)       | Manual scaling, HPA, postgres StatefulSet + PVC               |
| `hpa-loadtest.sh`         | 10 (bonus)       | Parallel-curl load generator to exercise the HPA              |
| `11-observability.sh`     | 11 (bonus)       | Installs kube-prometheus-stack, verifies Prometheus + Grafana |
| `90-teardown.sh`          | -                | Deletes the resource group (`--yes` to confirm)               |

> Section 3 is overview-only (no tasks). Section 9 (legacy NGINX Ingress) is intentionally not
> included; this harness uses the newer Gateway API (9a) instead. The bonus scripts (10, 11) are
> not part of `run-all.sh` because they are optional and resource-heavy.

## Notes & gotchas

- **Rendered manifests** are written to `rendered/` (git-ignored). The repo's source manifests under
  `../content/**` are never modified.
- **Idempotent**: every script can be re-run safely. The ACR name is generated once and pinned in
  `.acr_name`.
- **Bonus section 10** uses a parallel-`curl` load generator (`hpa-loadtest.sh`) because the upstream
  `hey` binary download is currently blocked.
- **Bonus section 11** adds real load to a small cluster. Access Grafana with
  `kubectl port-forward -n monitoring svc/kube-mon-grafana 3000:80` (login `admin` / `workshopAdmin`).
- **Long-running commands** (e.g. the Helm installs) are best run to completion; they can take a few
  minutes.

## Teardown

```bash
./90-teardown.sh          # dry run, shows what would be deleted
./90-teardown.sh --yes    # actually delete the resource group
```

To pause instead of delete (keeps the cluster but stops the node VMs to cut cost):

```bash
az aks stop  --resource-group "$RES_GROUP" --name "$AKS_NAME"
az aks start --resource-group "$RES_GROUP" --name "$AKS_NAME"
```
