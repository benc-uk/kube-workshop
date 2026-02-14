---
tags: extra
index: 13
title: Operations Cheat Sheet
summary:
  Running and maintaining a Kubernetes cluster is a complex task. This cheat sheet provides a quick reference to
  essential operations.
layout: default.njk
icon: 💊
---

# 💊 Operations Cheat Sheet

## Managing Deployments

- **Restart a Deployment**

  ```bash
  kubectl rollout restart deployment <deployment-name>
  ```

  Carry out a rolling restart of the deployment, which will restart all pods in the deployment without downtime.

- **Scale a Deployment**

  ```bash
  kubectl scale deployment <deployment-name> --replicas=<number-of-replicas>
  ```

  Use this command to scale the number of replicas in a deployment up or down.

- **Describe a Deployment**

  ```bash
  kubectl describe deployment <deployment-name>
  ```

  Use this command to get detailed information about the deployment, including events and conditions.

- **Update Image**

  ```bash
  kubectl set image deployment/<deployment-name> <container-name>=<new-image>
  ```

  Use this command to update the image of a container in a deployment without changing the deployment configuration.
  This will trigger a rolling update.  
  _Tip: To get the container name, you can use the describe command mentioned above._

## Helm Operations

- **List Helm Releases**

  ```bash
  helm list -A
  ```

  Use this command to list all the Helm releases in all namespaces.

- **Get Helm Release Values**

  ```bash
  helm get values <release-name>
  ```

  Use this command to retrieve the values used to install or upgrade a Helm release. Use the `--all` flag to get all
  values, including defaults.

- **Upgrade a Helm Release**

  ```bash
  helm upgrade <release-name> <chart-name> -f <values-file>
  ```

  Use this command to upgrade a Helm release with a new chart or values file.

- **Update a value in a Helm Release**

  ```bash
  helm upgrade <release-name> <chart-name> --set <key>=<value>
  ```

  Use this command to update a specific value in a Helm release without needing to provide a full values file.

- **Rollback a Helm Release**

  ```bash
  helm rollback <release-name> <revision-number>
  ```

  Use this command to roll back a Helm release to a previous revision, useful for undoing changes that caused issues.
  Use `helm history <release-name>` to find the revision number.

## Editing Resources

Use these commands to edit Kubernetes resources directly, but use them with caution as they can lead to unintended
consequences if not used properly and will be overwritten should the resource be updated by a controller or during a

- **Edit a Resource**

  ```bash
  kubectl edit <resource-type> <resource-name>
  ```

  Use this command to open the resource in your default editor and make changes directly to the live resource.

- **Patch a Resource**

  ```bash
  kubectl patch <resource-type> <resource-name> -p '{"spec":{"field":"new-value"}}'
  ```
