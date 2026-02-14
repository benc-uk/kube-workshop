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

| Operation                      | Command                                                           |
| ------------------------------ | ----------------------------------------------------------------- |
| Pod logs                       | `kubectl logs <pod-name>`                                         |
| See where a pod is running     | `kubectl get pods -o wide`                                        |
| Follow & watch pod logs        | `kubectl logs -f <pod-name>`                                      |
| Pod events & details           | `kubectl describe pod <pod-name>`                                 |
| Node status                    | `kubectl get nodes`                                               |
| Resource usage                 | `kubectl top nodes` and `kubectl top pods`                        |
| Exec into pods                 | `kubectl exec -it <pod-name> -- /bin/bash`                        |
| Run a shell inside a debug pod | `kubectl run --rm -it debug --image=alpine --restart=Never -- sh` |
| View & watch cluster events    | `kubectl get events -w`                                           |
| View cluster resources         | `kubectl get all`                                                 |

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

| Operation                     | Command                                                                                               |
| ----------------------------- | ----------------------------------------------------------------------------------------------------- |
| Port forward to a pod         | `kubectl port-forward <pod-name> <local-port>:<pod-port>`                                             |
| Get service details           | `kubectl describe service <service-name>`                                                             |
| Get ingress details           | `kubectl describe ingress <ingress-name>`                                                             |
| Test service connectivity     | `kubectl run --rm -it --image=alpine test-conn -- sh -c "apk add curl && curl <service-name>:<port>"` |
| Check endpoints for a service | `kubectl get endpointslice`                                                                           |

## Advanced Operations

| Operation        | Command                                                                          |
| ---------------- | -------------------------------------------------------------------------------- |
| Taint a node     | `kubectl taint nodes <node-name> key=value:NoSchedule`                           |
| Tolerate a taint | Add `tolerations` to your pod spec to allow it to be scheduled on tainted nodes. |
| Cordon a node    | `kubectl cordon <node-name>` (mark node as unschedulable)                        |
| Drain a node     | `kubectl drain <node-name> --ignore-daemonsets` (safely evict pods from a node)  |
