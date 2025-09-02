# ✨ The Path to Production Readiness

We've cut several corners so far in order to simplify things and introduce concepts one at a time, now it is time to
make some improvements. What constitutes best practice is a moving target, and often subjective, but there are some
things we can do to make our deployment a little more robust and production ready.

This section will introduce several new Kubernetes concepts, and we'll also pick up the pace a little with slightly less
"hand holding".

## 🌡️ Resource Requests & Limits

We have not given Kubernetes any information on the system resources (CPU & memory) our applications requires, but we
can do this two ways:

- **Resource requests**: Used by the Kubernetes scheduler to help assign _Pods_ to a node with sufficient resources.
  This is only used when starting & scheduling pods, and not enforced after they start.
- **Resource limits**: _Pods_ will be prevented from using more resources than their assigned limits. These limits are
  enforced and can result in a _Pod_ being terminated. It's highly recommended to set limits to prevent one workload
  from monopolizing cluster resources and starving other workloads.

It's worth reading the offical docs especially on the units & specifiers used for memory and CPU, which can feel a
little unintuitive at first.

[📚 Kubernetes Docs: Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

You can specify resources of these within the pod template inside the _Deployment_ YAML. The `resources` section needs
to go at the same level as `image`, `ports` in the spec.

```yaml
# Resources to set on both frontend & API deployment
resources:
  requests:
    cpu: 50m
    memory: 50Mi
  limits:
    cpu: 100m
    memory: 128Mi
```

```yaml
# Resources to set on PostgreSQL deployment
resources:
  requests:
    cpu: 50m
    memory: 100Mi
  limits:
    cpu: 100m
    memory: 512Mi
```

> 📝 NOTE: If you were using VS Code to edit your manifests and had the Kubernetes extension installed, you might have
> noticed scary yellow warnings in the editor until this point, the lack of resource limits was the cause of this.

Add these sections to your deployment YAML files, and reapply to the cluster with `kubectl` as before and check the
status and that the pods start up. These values are extremely conservative, but should be sufficient for such a
non-demanding application and demonstration purposes.

## 💓 Readiness & Liveness Probes

Probes are Kubernetes' way of checking the health of your workloads. There are two main types of probe:

- **Liveness probe**: Checks if the _Pod_ is alive, _Pods_ that fail this probe will be **_terminated and restarted_**
- **Readiness probe**: Checks if the _Pod_ is ready to **_accept traffic_**, _Services_ only sends traffic to _Pods_
  which are in a ready state.

[📚 Kubernetes Docs: Configure Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

Also [this blog post](https://srcco.de/posts/kubernetes-liveness-probes-are-dangerous.html) despite being old, has some
excellent advice around probes, and covers some of the pitfalls of using them, particularly liveness probes.

For this workshop we'll only set up a readiness probe, which is the most common type:

```yaml
# Probe to add to the API deployment in the same level as above
# Note: this container exposes a specific health endpoint
readinessProbe:
  httpGet:
    port: 8000
    path: /api/health
  initialDelaySeconds: 5
  periodSeconds: 10
```

```yaml
# Probe to add to the frontend deployment
readinessProbe:
  httpGet:
    path: /
    port: 8001
  initialDelaySeconds: 5
  periodSeconds: 10
```

Add these sections to your deployment YAML files, at the same level in the YAML as the resources block. Reapply to the
cluster with `kubectl` as before, and check the status and that the pods start up.

If you run `kubectl get pods` immediately after the apply, you should see that the pods status will be "Running", but
will show "0/1" in the ready column, until the probe runs & passes for the first time.

## 🔐 Secrets

Remember how we had the database password visible in plain text in two of our deployment YAML manifests? Blergh! 🤢 Now
is the time to address that, we can create a Kubernetes _Secret_, which is a configuration resource which can be used to
store sensitive information.

[📚 Kubernetes Docs: Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

_Secrets_ can be created using a YAML file just like every resource in Kubernetes, but instead we'll use the
`kubectl create` command to imperatively create the resource from the command line, as follows:

```bash
kubectl create secret generic database-creds \
--from-literal password='kindaSecret123!'
```

A _Secrets_ resource can contain multiple keys, but here we add a single key one for the datbase user password called
`password`

_Secrets_ can be used a number of ways, but the easiest way to consume them, is as environmental variables passed into
your containers. Update the deployment YAML for **BOTH your API, and PostgreSQL deployments**, replace the reference to
`POSTGRES_PASSWORD` in both places as shown below:

```yaml
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: database-creds
      key: password
```

> 📝 NOTE: _Secrets_ aren't quite as secret as they sound, they are not encypted and are simply stored as base-64
> encoded values. Gasp! They mainly keep any plain text values out of our manifests. Anyone with the relevant cluster
> priviledges will be able to read the values of _Secrets_ easily. If you want further encryption and isolation a number
> of options are available including Mozilla SOPS, Hashicorp Vault and Azure Key Vault.

## 🖼️ Cluster & Architecture Diagram

Desptite the improvements we've made, the fundamental architecture of our deployment has not significantly changed
beyond the addition of a _Secret_ resource, so we'll skip the diagram this time.

## 🔍 Reference Manifests

If you get stuck and are looking for working manifests you can refer to, they are available here:

- [api-deployment.yaml](api-deployment.yaml)
- [frontend-deployment.yaml](frontend-deployment.yaml)
- [postgres-deployment.yaml](postgres-deployment.yaml)
  - Bonus: This manifest shows how to add a probe using an executed command, rather than a HTTP request, use it if you
    wish, but it's optional.

## Navigation

[Return to Main Index 🏠](../readme.md) ‖ [Previous Section ⏪](../06-frontend/readme.md) ‖
[Next Section ⏩](../08-more-improvements/readme.md)
