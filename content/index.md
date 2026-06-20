---
title: Kubernetes Developer Workshop
layout: default.njk
---

# Kubernetes Developer Workshop

Welcome to the 'Kubernetes Developer Workshop'. This isn't a lecture or a pile of theory to read through, it's a set of
hands on exercises where you'll actually deploy and run a real application on Kubernetes. You'll spend your time in the
terminal and working with live clusters, building up genuine, practical experience as you go.

It's aimed at software engineers and developers with little or zero Kubernetes experience who want to roll up their
sleeves and learn by doing, rather than just reading about it. By the end you'll have real, hands on experience of
deploying and managing your code in Kubernetes.

Although it's called a workshop, the name is a little misleading. It's flexible in how you use it, it can be run as a
guided workshop or training session, alternatively work through it at your own pace as self-paced learning, or just dip
into individual sections as a reference guide when you need them.

Plan for roughly 6 to 8 hours to get through the main sections, though that's a rough guide so go at your own pace. If
you want some background reading alongside it, or before you start, the
[Kubernetes Technical Primer](https://kube-primer.benco.io/) makes a companion for grounding yourself in the concepts.

You will stand up a cluster as part of the workshop, but we won't be getting into the administration, network
configuration or day-2 operations of Kubernetes itself. This is squarely a developer's workshop, so if you're after the
low level or operational side of running Kubernetes clusters, this probably isn't the place for you.

The app you'll be deploying is already written and built, so you won't need to write any application code yourself.

Stuck on something? The [GitHub source repo for this workshop](https://github.com/benc-uk/kube-workshop) has example
code and working files for every section.

## Azure Kubernetes Service (AKS)

The main workshop is built around Azure Kubernetes Service (AKS), but almost none of the content is actually specific to
AKS, so you can happily follow along on any Kubernetes cluster. That said, to follow the main content as written you'll
need access to an Azure subscription to spin up the AKS cluster and the other resources.

Workshop sections & topics:

<ul>
  {%- for section in collections.section -%}
  <li>
    <a href="{{ section.page.url }}"
      >{{ section.data.index | zeroPad }}: {{ section.data.icon }} {{ section.data.title }}</a
    > - {{ section.data.summary }}
  </li>
  {%- endfor -%}
</ul>

> Some familiarity with Azure is required for sections 1 and 2, but after that the focus is on Kubernetes itself.

### 🍵 Optional Sections

These can be considered bonus sections, and are entirely optional. It is not expected that all these sections would be
attempted, and they do not run in order.

<ul>
  {%- for section in collections.extra -%}
  <li>
    <a href="{{ section.page.url }}"
      >{{ section.data.index | zeroPad }}: {{ section.data.icon }} {{ section.data.title }}</a
    > - {{ section.data.summary }}
  </li>
  {%- endfor -%}
</ul>

### 📌 Using 'Kind' Instead of AKS

The workshop was designed with AKS in mind, but if you don't have access to Azure or prefer to do your development and
testing locally, you can use [Kind (Kubernetes IN Docker)](https://kind.sigs.k8s.io/) to create a local Kubernetes
cluster. Kind runs Kubernetes clusters locally in Docker containers, making it an excellent tool for local development
and testing.

Below is a link to notes and modifications for if you want to try this path. It's not a section in the main flow of the
workshop, but rather a separate page with notes and alternative instructions for each of the main sections of the
workshop (above)

- [Using Kind instead of Azure Kubernetes Service](99-kind)

### 📖 Extra Reading & Teach Yourself Exercises

A very brief list of potential topics and Kubernetes features you may want to look at after finishing:

#### Kubernetes Features

- [Init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [Debugging Pods with shell access and exec](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/)
- Assigning Pods to Nodes with [selectors](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) and
  [taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
- [Cluster Autoscaler in AKS](https://docs.microsoft.com/azure/aks/cluster-autoscaler)

#### Other Projects

- Enable the [Kubernetes dashboard](https://github.com/kubernetes/dashboard)
- Enabling TLS with certificates from Let's Encrypt using [Cert Manager](https://cert-manager.io/docs/)
- Observability
  - With [Prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus) &
    [Grafana](https://artifacthub.io/packages/helm/grafana/grafana)
  - Using [AKS monitoring add-on](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-overview)
- Using [Dapr](https://dapr.io/) for building portable and reliable microservices
- Adding a service mesh such as [Linkerd](https://linkerd.io/) or
  [Istio](https://learn.microsoft.com/en-us/azure/aks/istio-about)
- Setting up the
  [Application Gateway for Containers](https://learn.microsoft.com/en-gb/azure/application-gateway/for-containers/overview)

### 🗝️ Archived: K3S Path

If you wish to learn how to set up and run Kubernetes on a single VM, simulating an on-premises environment, then you
can follow the K3S version of this workshop. This is no longer actively maintained and will be out of date, but is kept
for reference purposes. Refer to the [archived K3S section](archive/k3s/) for more details.
