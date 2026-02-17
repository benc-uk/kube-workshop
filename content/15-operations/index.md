---
tags: extra
index: 15
title: Operations Cheat Sheet
summary: This cheat sheet provides a quick reference to essential operations.
layout: default.njk
icon: 💊
---

# 💊 Operations Cheat Sheet

This cheat sheet is broken in to sections covering different aspects of Kubernetes operations, from basic commands to
more advanced topics. Use it as a quick reference guide when working with your cluster.

## Investigate & Debug

| Operation                            | Command                                                                 |
| ------------------------------------ | ----------------------------------------------------------------------- |
| Pod logs                             | `kubectl logs <pod-name>`                                               |
| See where a pod is running           | `kubectl get pods -o wide`                                              |
| Follow & watch pod logs              | `kubectl logs -f <pod-name>`                                            |
| Pod events & details                 | `kubectl describe pod <pod-name>`                                       |
| Node status                          | `kubectl get nodes`                                                     |
| Resource usage                       | `kubectl top nodes` and `kubectl top pods`                              |
| Exec into pods                       | `kubectl exec -it <pod-name> -- /bin/bash`                              |
| Debug a pod with ephemeral container | `kubectl debug -it <pod-name> --image=alpine --target=<container-name>` |
| Run a shell inside a debug pod       | `kubectl run --rm -it debug --image=alpine --restart=Never -- sh`       |
| View & watch cluster events          | `kubectl get events -w`                                                 |
| Logs from a previous/crashed pod     | `kubectl logs <pod-name> --previous`                                    |
| Find non-running pods                | `kubectl get pods --field-selector=status.phase!=Running`               |

## Remediate & Manage

| Operation            | Command                                                                       |
| -------------------- | ----------------------------------------------------------------------------- |
| Restart a pod        | `kubectl delete pod <pod-name>` (it will be recreated by the deployment)      |
| Restart a deployment | `kubectl rollout restart deployment <deployment-name>`                        |
| Scale a deployment   | `kubectl scale deployment <deployment-name> --replicas=<number>`              |
| Update an image      | `kubectl set image deployment/<deployment-name> <container-name>=<new-image>` |
| Apply a manifest     | `kubectl apply -f <manifest-file.yaml>`                                       |
| Edit a resource live | `kubectl edit <resource-type> <resource-name>`                                |

## Network & Services

| Operation                      | Command                                                                                               |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- |
| Port forward to a pod          | `kubectl port-forward <pod-name> <local-port>:<pod-port>`                                             |
| Get service details            | `kubectl describe service <service-name>`                                                             |
| Get ingress details            | `kubectl describe ingress <ingress-name>`                                                             |
| Test service connectivity      | `kubectl run --rm -it --image=alpine test-conn -- sh -c "apk add curl && curl <service-name>:<port>"` |
| Check endpoints for a service  | `kubectl get endpointslice`                                                                           |
| Port forward to a service      | `kubectl port-forward svc/<service-name> <local-port>:<service-port>`                                 |
| DNS lookup from inside cluster | `kubectl run --rm -it dns-test --image=busybox --restart=Never -- nslookup <service-name>`            |
| View network policies          | `kubectl get networkpolicy`                                                                           |

## Advanced Operations

| Operation        | Command                                                                          |
| ---------------- | -------------------------------------------------------------------------------- |
| Taint a node     | `kubectl taint nodes <node-name> key=value:NoSchedule`                           |
| Tolerate a taint | Add `tolerations` to your pod spec to allow it to be scheduled on tainted nodes. |
| Cordon a node    | `kubectl cordon <node-name>` (mark node as unschedulable)                        |
| Drain a node     | `kubectl drain <node-name> --ignore-daemonsets` (safely evict pods from a node)  |
| Uncordon a node  | `kubectl uncordon <node-name>` (mark node as schedulable again)                  |
| Remove a taint   | `kubectl taint nodes <node-name> key=value:NoSchedule-` (note the trailing `-`)  |

## Rollbacks & History

| Operation                    | Command                                                             |
| ---------------------------- | ------------------------------------------------------------------- |
| View rollout history         | `kubectl rollout history deployment <deployment-name>`              |
| Rollback to previous version | `kubectl rollout undo deployment <deployment-name>`                 |
| Rollback to specific version | `kubectl rollout undo deployment <deployment-name> --to-revision=2` |
| Check rollout status         | `kubectl rollout status deployment <deployment-name>`               |

## Configuration & Secrets

| Operation                      | Command                                                                    |
| ------------------------------ | -------------------------------------------------------------------------- |
| List configmaps                | `kubectl get configmaps`                                                   |
| View a configmap               | `kubectl describe configmap <configmap-name>`                              |
| List secrets                   | `kubectl get secrets`                                                      |
| Decode a secret value          | `kubectl get secret <name> -o jsonpath='{.data.<key>}' \| base64 --decode` |
| Create a secret from literals  | `kubectl create secret generic <name> --from-literal=key=value`            |
| Create a configmap from a file | `kubectl create configmap <name> --from-file=<path>`                       |

## Resource Inspection

| Operation                          | Command                                                      |
| ---------------------------------- | ------------------------------------------------------------ |
| Get resource as YAML               | `kubectl get <resource> <name> -o yaml`                      |
| Get resource as JSON               | `kubectl get <resource> <name> -o json`                      |
| Extract a field with JSONPath      | `kubectl get pods -o jsonpath='{.items[*].metadata.name}'`   |
| Diff live state vs. local manifest | `kubectl diff -f <manifest-file.yaml>`                       |
| Show resource in a specific ns     | `kubectl get pods -n <namespace>`                            |
| Show resources in all namespaces   | `kubectl get pods --all-namespaces` or `kubectl get pods -A` |

## Context & Namespace Management

| Operation             | Command                                                        |
| --------------------- | -------------------------------------------------------------- |
| View current context  | `kubectl config current-context`                               |
| Set default namespace | `kubectl config set-context --current --namespace=<namespace>` |
| List all contexts     | `kubectl config get-contexts`                                  |
| Switch context        | `kubectl config use-context <context-name>`                    |
| View cluster info     | `kubectl cluster-info`                                         |
| List all namespaces   | `kubectl get namespaces`                                       |

## Cleanup

| Operation                         | Command                                                    |
| --------------------------------- | ---------------------------------------------------------- |
| Delete a resource                 | `kubectl delete <resource-type> <name>`                    |
| Delete resources from a manifest  | `kubectl delete -f <manifest-file.yaml>`                   |
| Force delete a stuck pod          | `kubectl delete pod <pod-name> --grace-period=0 --force`   |
| Delete all pods in a namespace    | `kubectl delete pods --all -n <namespace>`                 |
| Remove completed/failed jobs      | `kubectl delete jobs --field-selector status.successful=1` |
| Prune resources not in a manifest | `kubectl apply -f <directory> --prune -l <label-selector>` |
