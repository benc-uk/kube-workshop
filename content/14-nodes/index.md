---
tags: extra
index: 14
title: Nodes & Scheduling
summary: A look at the underlying nodes that run workloads, and how to control pod scheduling
layout: default.njk
icon: ⚙️
---

# {{ icon }} {{ title }}

In this section we'll take a look at the the nodes that run our workloads. This is not strictly necessary to know in
order to deploy and run applications, but it is useful to understand the fundamentals of how Kubernetes works under the
hood, and it will give you a better understanding of the cluster and how to troubleshoot it when things go wrong.

This section is a little more Azure & AKS specific, as we'll be taking about nodepools and some specifics of how AKS
manages nodes. However the concepts of nodes, labels, selectors, taints, and tolerations are all fundamental Kubernetes
concepts that apply to any cluster, regardless of where it's running.

In Kubernetes, the term "node" refers to a machine in the cluster, you might also see them referred to as "worker nodes"
or "agent nodes".

> Note. We won't be going into cluster level networking, i.e. how nodes and pods communicate with each other, VNets or
> how services route traffic to pods, otherwise this would be a 2 week deep dive! If you are really interested in that,
> check out [Kubernetes networking concepts](https://kubernetes.io/docs/concepts/cluster-administration/networking/).
> For AKS specific networking, check out the
> [AKS CNI networking overview](https://learn.microsoft.com/en-gb/azure/aks/concepts-network-cni-overview)

## 🏗️ Cluster Architecture Overview

Every Kubernetes cluster consists of two main parts:

- **Control plane**: The "brains" of the cluster. It manages the overall state of the cluster, schedules workloads, and
  responds to events (like a pod crashing). In AKS this is fully managed by Azure — you don't see or pay for the VMs
  running it. The control plane includes components like the API server, etcd (the cluster database), the scheduler, and
  controller manager.
- **Worker nodes**: These are the VMs (or physical machines) where your application _Pods_ actually run. In AKS, these
  are Azure Virtual Machines that you _do_ pay for, and they are organized into **node pools** which are backed with
  [Azure VM Scale Sets](https://learn.microsoft.com/en-us/azure/virtual-machine-scale-sets/overview).

When you created your AKS cluster back in section 1, you specified `--node-count 2`, which created a single node pool
with two worker nodes. The control plane was provisioned for you transparently by Azure.

The following diagram shows a high-level view of a Kubernetes cluster architecture, with the control plane, system node
pool, and user node pools. Don't worry about understanding every component in the diagram, just get a sense of how the
control plane manages the nodes and how the system node pool runs critical cluster infrastructure while user node pools
run your application workloads.

<img src="cluster-architecture.drawio.svg" alt="Kubernetes cluster architecture diagram showing the control plane, system node pool, and user node pool" style="max-width: 100%; margin: 1rem 0;">

[📚 Kubernetes Docs: Cluster Architecture](https://kubernetes.io/docs/concepts/architecture/)

## 🔍 Exploring Nodes

Let's start by listing the nodes in the cluster:

```bash
kubectl get nodes -o wide
```

This will show you the nodes with additional detail including the OS image, kernel version, container runtime, and
internal IP addresses. You should see two nodes, both with a status of `Ready`.

To get much more detailed information about a specific node, use `describe`:

```bash
kubectl describe node <node-name>
```

This command outputs a wealth of information. Some key sections to look at:

- **Labels**: Metadata attached to the node. AKS automatically adds labels such as the node pool name, OS, VM size, and
  availability zone. Labels are critical for scheduling decisions.
- **Conditions**: Shows the health status of the node — whether it has sufficient memory, disk space, and if it's ready
  to accept pods.
- **Capacity vs Allocatable**: The total resources on the node (capacity) versus what's actually available for your
  workloads (allocatable). The difference is reserved for the OS and Kubernetes system components like the kubelet.
- **Non-terminated Pods**: A list of every pod running on that node, including system pods in the `kube-system`
  namespace.
- **Allocated resources**: A summary of how much CPU and memory has been _requested_ by pods on that node, and how much
  of the node's capacity is committed.

🧪 **Experiment**: Run `kubectl describe node` on one of your nodes and look at the "Allocated resources" section. How
much of the node's CPU and memory is being used by requests? If you scaled up a deployment to many replicas, what would
happen when the node runs out of allocatable resources?

## 📦 Node Components

Each worker node runs a few essential components that keep it functioning as part of the cluster. The most important is
the **kubelet** — the primary agent on each node that communicates with the control plane and ensures containers are
running. It runs as a system service directly on the node (not as a pod), so you won't see it in `kubectl` output. The
**container runtime** (`containerd` on AKS) is the software that actually runs the containers.

Beyond those invisible node-level services, AKS deploys a number of system pods into the `kube-system` namespace. Let's
take a look:

```bash
kubectl get pods -n kube-system -o wide
```

You'll see quite a few pods here, some of the notable ones include:

- **kube-proxy** — Manages network rules on each node, enabling _Service_ routing to the correct pods.
- **CoreDNS** — Provides DNS resolution within the cluster, so pods can find _Services_ by name (e.g.
  `postgres.default.svc.cluster.local`).
- **CSI drivers** (e.g. `csi-azuredisk`, `csi-azurefile`) — Container Storage Interface drivers that allow pods to use
  Azure Disks and Azure Files as persistent volumes.
- **cloud-node-manager** — An Azure-specific component that keeps the Kubernetes node objects in sync with the
  underlying Azure VMs.
- **metrics-server** — Collects resource usage data from the kubelets, which powers `kubectl top`.

Don't worry about understanding all of these — the key point is that a lot of infrastructure runs in the background to
keep your cluster operational, and much of it is visible in the `kube-system` namespace.

## 🏊 Adding A Second Node Pool

To really explore node scheduling and placement, it helps to have more than one node pool. Let's add a second small pool
called `extra` with a single node. This will give us a concrete target for node selectors, taints, and other scheduling
features we'll explore in this section.

```bash
az aks nodepool add \
  --resource-group $RES_GROUP \
  --cluster-name $AKS_NAME \
  --name extra \
  --node-count 1 \
  --node-vm-size Standard_B2ms \
  --labels workload=extra
```

This will take a couple of minutes. Once it completes, verify the new node has joined the cluster:

```bash
kubectl get nodes -o wide
```

You should now see three nodes — two from your original `nodepool1` and one from the new `extra` pool. Note down the
name of the node in the `extra` pool, you'll need it later. You can easily identify it with:

```bash
kubectl get nodes -l agentpool=extra
```

> Adding a node pool will increase your Azure costs. Remember to remove it when you're done with this section using:
> `az aks nodepool delete --resource-group $RES_GROUP --cluster-name $AKS_NAME --name extra`

## 🏷️ Labels & Selectors

Until now we've been deploying our workloads without any control over which nodes they run on — the Kubernetes scheduler
has been placing them wherever it sees fit based on resource availability. This is fine for many workloads, but
sometimes you want more control over where your pods run. This is where **labels** and **selectors** come in.

Nodes use labels extensively, and understanding them is key to controlling where your workloads run. Let's see what
labels are on your nodes:

```bash
kubectl get nodes --show-labels
```

The output will be quite verbose! Some important labels that AKS sets automatically include:

- `kubernetes.io/os` — The operating system (typically `linux`).
- `node.kubernetes.io/instance-type` — The Azure VM size, e.g. `Standard_B2ms`.
- `topology.kubernetes.io/zone` — The Azure availability zone, if your cluster uses them.
- `agentpool` — The name of the AKS node pool.

Notice the `agentpool` label — your original nodes will show `agentpool=nodepool1` while the new node shows
`agentpool=extra`. You should also see the custom label `workload=extra` on the new node, which we set when creating the
pool.

These labels become very powerful when combined with **node selectors** or **node affinity** rules in your pod specs,
which let you control which nodes a pod can be scheduled on.

## 🎯 Node Selectors & Affinity

The simplest way to influence pod scheduling is with a `nodeSelector`. This is added to your pod template spec and tells
the scheduler to only place the pod on nodes matching specific labels.

Let's try this with the `extra` node pool we just created. We can target it using the `agentpool` label that AKS
automatically sets, or the custom `workload` label we added. Let's use our custom label:

Edit the deployment manifest for your API and add a `nodeSelector`:

```yaml
spec:
  # Extra stuff omitted for brevity
  spec:
    # Place this just above the containers: section
    nodeSelector:
      workload: extra
```

Now apply the updated manifest with `kubectl apply -f` and watch what happens to the pods:

```bash
kubectl get pods -l app=nanomon-api -o wide
```

You should see all the API pods running on the `extra` node. Remove the `nodeSelector` and reapply to restore normal
scheduling.

For more sophisticated scheduling, Kubernetes offers **node affinity**, which provides richer matching expressions
including "preferred" (soft) and "required" (hard) rules.

[📚 Kubernetes Docs: Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)

Here's an example of a preferred node affinity that _tries_ to schedule pods on the `extra` pool, but doesn't fail if
the node is unavailable. You don't need to update your manifest to test this — just read through the example to
understand how it works:

```yaml
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 1
          preference:
            matchExpressions:
              - key: agentpool
                operator: In
                values:
                  - extra
  containers:
    - name: nanomon-api
      image: __ACR_NAME__.azurecr.io/nanomon-api:latest
```

The difference between "preferred" and "required" is important — a required rule
(`requiredDuringSchedulingIgnoredDuringExecution`) will cause pods to remain in a `Pending` state if no matching node is
available, while a preferred rule will fall back to any available node.

## 🪣 Taints & Tolerations

Taints and tolerations work alongside node selectors, but in the _opposite direction_. While node selectors attract pods
to certain nodes, **taints** are used to _repel_ pods from nodes unless they explicitly **tolerate** the taint.

A taint is applied to a node and has three parts: a key, a value, and an effect. The effect can be:

- `NoSchedule` — New pods without a matching toleration will not be scheduled on this node.
- `PreferNoSchedule` — The scheduler will _try_ to avoid placing pods here, but it's not guaranteed.
- `NoExecute` — Existing pods without a matching toleration will be evicted from the node.

Let's use our `extra` node pool to see this in action. First, taint the `extra` node so that normal pods are repelled
from it:

```bash
kubectl taint nodes -l agentpool=extra dedicated=special:NoSchedule
```

> Here we use `-l agentpool=extra` to target the node by label rather than by name, which is often more convenient.

Now scale up a deployment and see what happens:

```bash
kubectl scale deployment nanomon-api --replicas 6
kubectl get pods -l app=nanomon-api -o wide
```

Wait why aren't any pods starting they are all pending! Well we still have the node selector in the manifest that is
forcing all the pods to be scheduled on the `extra` node, but now we have a taint on that node that is preventing any
pods from being scheduled there. So we have a scheduling conflict — the node selector says "schedule here" but the taint
says "don't schedule here". The result is that the pods remain in a `Pending` state indefinitely.

You could remove the node selector to allow the pods to be scheduled on the other nodes, but let's instead add a
toleration to allow the pods to be scheduled on the tainted node:

```yaml
spec:
  # Extra stuff omitted for brevity
  spec:
    tolerations:
      - key: "dedicated"
        operator: "Equal"
        value: "special"
        effect: "NoSchedule"
    # Lines below remain unchanged
    nodeSelector:
      workload: extra
```

Note that we combine the toleration with a `nodeSelector` — the toleration _allows_ the pod to run on the tainted node,
but doesn't _force_ it there. The `nodeSelector` handles the placement.

[📚 Kubernetes Docs: Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

When you're done experimenting, remove the taint and scale back down:

```bash
kubectl taint nodes -l agentpool=extra dedicated=special:NoSchedule-
kubectl scale deployment nanomon-api --replicas 2
```

The trailing `-` on the taint command removes it, which is easy to be mistaken for a typo, so be careful!

## 📊 Resource Monitoring

Back in section 7 we set resource requests and limits on our pods. But how do we see _actual_ resource usage on the
nodes? The `kubectl top` command gives us a quick view:

```bash
# Show resource usage per node
kubectl top nodes

# Show resource usage per pod
kubectl top pods
```

This shows the real-time CPU and memory consumption. Comparing these values with the node's allocatable resources (from
`kubectl describe node`) gives you a good sense of how much headroom you have.

> If `kubectl top` returns an error, it means the metrics server isn't installed. In AKS, this is typically enabled by
> default, but you can install it with
> `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`

## 🛠️ Node Maintenance & Cordoning

Sometimes you need to take a node out of service for maintenance, upgrades, or troubleshooting. This sort of cluster
level operation is not common for application developers, but an awareness of how it works is useful for understanding
cluster operations and troubleshooting.

There are three main activities for managing node availability:

- **Cordoning a node**: This marks the node as unschedulable, preventing new pods from being scheduled on it, but does
  not affect existing pods. `kubectl cordon <node-name>`
- **Draining a node**: This evicts all pods from the node and marks it as unschedulable. This is used for maintenance or
  decommissioning. `kubectl drain <node-name> --ignore-daemonsets`
- **Uncordoning a node**: This marks a previously cordoned or drained node as schedulable again, allowing pods to be
  scheduled on it. `kubectl uncordon <node-name>`

## 🔁 DaemonSets

You may have noticed the `--ignore-daemonsets` flag in the drain command above, and wondered what a DaemonSet is. If you
looked at the system pods in `kube-system` earlier, you might also have noticed that some pods (like `kube-proxy` and
the CSI drivers) have one instance running on _every_ node. That's because they are managed by a _DaemonSet_.

A _DaemonSet_ is a workload resource (like a _Deployment_) but instead of running a set number of replicas, it ensures
that a copy of a pod runs on **every node** in the cluster. When a new node is added, the DaemonSet automatically
schedules a pod onto it. When a node is removed, the pod is cleaned up. You don't specify a `replicas` count — the
number of pods is determined by the number of nodes.

This makes DaemonSets ideal for node-level infrastructure concerns such as:

- Log collection agents (e.g. Fluentd, Fluent Bit)
- Monitoring and metrics exporters (e.g. Prometheus node-exporter)
- Network plugins and proxies (e.g. kube-proxy)
- Storage drivers (e.g. CSI node plugins)

You can see the DaemonSets running in your cluster with:

```bash
kubectl get daemonsets -A
```

Notice how the `DESIRED` and `CURRENT` columns match for each DaemonSet — that's telling you every node has its required
pod running. DaemonSets can also use node selectors to target only a subset of nodes if needed.

[📚 Kubernetes Docs: DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)

## 🏊 Node Pools In Practice

We've already been using node pools throughout this section — the `extra` pool we created earlier is a great example. In
AKS, nodes are organized into **node pools**, groups of nodes with the same VM size and configuration.

In production, it's common to have several node pools with different characteristics:

- A **system pool** with small VMs for running critical cluster infrastructure (CoreDNS, kube-proxy, etc.). You should
  not run your application workloads on this pool, if your application was to misbehave, it could impact the stability
  of the entire cluster.
- A **general pool** with mid-sized VMs for typical application workloads.
- A **compute pool** with large or GPU-equipped VMs for data processing or machine learning.
- A **spot pool** using Azure Spot VMs for fault-tolerant batch workloads at reduced cost.

You can manage your node pools with the Azure CLI, for example listing the pools in your cluster:

```bash
az aks nodepool list --resource-group $RES_GROUP --cluster-name $AKS_NAME -o table
```

You should see both `nodepool1` and `extra` listed. The combination of node pools with the labels, selectors, taints,
and tolerations we explored above gives you fine-grained control over workload placement.

[📚 AKS Docs: Node Pools](https://learn.microsoft.com/azure/aks/create-node-pools)

## 🧹 Cleanup

If you added the `extra` node pool during this section, now is a good time to remove it to avoid unnecessary Azure
costs:

```bash
az aks nodepool delete --resource-group $RES_GROUP --cluster-name $AKS_NAME --name extra --no-wait
```

The `--no-wait` flag returns immediately while the deletion happens in the background. Your pods will be rescheduled
onto the remaining nodes automatically.

If you still have your API pods pinned to the `extra` node with a `nodeSelector`, you'll notice your API pods are now in
a `Pending` state after the node pool is deleted. Remove the `nodeSelector` from your manifest and reapply to restore
normal scheduling.

## 🧠 Key Takeaways

Understanding nodes and cluster architecture might seem like "infrastructure plumbing", but it's knowledge that pays off
when things go wrong. Here's a quick summary of what we covered:

- The cluster is split into a **control plane** (managed by AKS) and **worker nodes** (your VMs).
- Nodes run the **kubelet**, **kube-proxy**, and a **container runtime**.
- **Node pools** in AKS let you run heterogeneous hardware in the same cluster.
- **Labels**, **node selectors**, and **affinity** rules let you control pod placement.
- **Taints and tolerations** let you reserve or restrict nodes.
- **Cordoning and draining** safely remove nodes from service.
- **Resource monitoring** with `kubectl top` helps you understand utilization.
