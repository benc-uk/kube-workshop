# Improving The Deployment

We've cut a few corners so far in order to simplify things, now is time to make some simple improvements

## Resource Requests & Limits

We have not given Kubernetes any clue on the CPU or memory resources our applications need or will use, but we can do this two ways:

- **Resource requests**: Used by the Kubernetes scheduler to help assign *Pods* to a node with sufficient resources. This is only used when starting & scheduling pods, and not enforced after they start.
- **Resource limits**: *Pods* will be prevented from using more resources than their assigned limits. These limits are enforced and can result in a *Pod* being terminated. It's highly recommended to set limits to prevent one workload from monopolizing cluster resources and starving other workloads.

It's worth reading the [Kubernetes documentation on this topic](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/), especially on the units & specifiers used for memory and CPU.

You can specify resources of these within the pod template inside the Deployment YAML. The `resources` section needs to go at the same level as `image`, `ports` and `env` in the spec.

```yaml
# Resources to set on frontend & data API deployment
resources:
  requests:
    cpu: 50m
    memory: 50Mi
  limits:
    cpu: 100m
    memory: 100Mi

# Resources to set on MongoDB deployment
resources:
  requests:
    cpu: 100m
    memory: 200Mi
  limits:
    cpu: 500m
    memory: 300Mi
```

> 📝 NOTE: If you were using VS Code to edit your YAML and had the Kubernetes extension installed you might have noticed yellow warnings in the editor. The lack of resource limits was the cause of this.

## Liveness Probes
## Secrets