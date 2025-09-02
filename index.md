---
title: Kubernetes Developer Workshop
layout: default.njk
---

# Kubernetes Developer Workshop

Welcome to the 'Kubernetes Developer Workshop', a highly technical & hands on set of exercises intended to get you
comfortable working with Kubernetes, and deploying applications within it. This workshop is very much aimed at software
engineers & developers with little or zero Kubernetes experience, but wanting to get hands on and learn how to deploy
and manage their code in a Kubernetes.

It should take roughly 6~8 hours to complete the main set of sections, but this is very approximate. This
[Kubernetes Technical Primer](https://github.com/benc-uk/kube-primer) can act as a companion to the workshop to be read
through, referenced or used to get an initial grounding on the concepts.

The installation, administration, network configuration & day-2 operations of Kubernetes itself, are not covered in this
workshop. This is very much a developer focused workshop, so if you want to learn about the low level & operational side
of Kubernetes you might want to look elsewhere.

The workshop focuses on an application that has already been written and built, so no application code will need to be
written.

If you get stuck, the [GitHub source repo for this workshop](https://github.com/benc-uk/kube-workshop) contains example
code, and working files for all of the sections.

## Azure Kubernetes Service (AKS)

You'll be using AKS to learn how to work with Kubernetes running as a managed service in Azure.

> This section assumes a relative degree of comfort in using Azure for sections 2 and 3.

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

### 🍵 Optional Sections

These can be considered bonus sections, and are entirely optional. It is not expected that all these sections would be
attempted, and they do not run in order.

<ul>
  {%- for section in collections.section-extra -%}
  <li>
    <a href="{{ section.page.url }}"
      >{{ section.data.index | zeroPad }}: {{ section.data.icon }} {{ section.data.title }}</a
    > - {{ section.data.summary }}
  </li>
  {%- endfor -%}
</ul>

### 🗝️ Archive: K3S Path

If you wish to learn how to set up and run Kubernetes on a single VM, simulating an on-premises environment, then you
can follow the K3S version of this workshop. This is no longer actively maintained and will be out of date, but is kept
for reference purposes. Refer to the [archived K3S section](archive/k3s/) for more details.

### 📖 Extra Reading & Teach Yourself Exercises

A very brief list of potential topics and Kubernetes features you may want to look at after finishing:

### Kubernetes Features

- [Init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [Debugging Pods with shell access and exec](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/)
- Assigning Pods to Nodes with [selectors](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) and
  [taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
- [Cluster Autoscaler in AKS](https://docs.microsoft.com/azure/aks/cluster-autoscaler)

### Other Projects

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
