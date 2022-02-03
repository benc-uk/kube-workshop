# Kubernetes Developer Workshop

This is a hands-on, technical workshop intended / hack to get comfortable working with Kubernetes and deploying & configuring applications. It should hopefully take roughly 4~5 hours to complete the main set of sections. This workshop is intended partially as a companion to this [Kubernetes Technical Primer](https://github.com/benc-uk/kube-primer) which can be read through, referenced or used to get an initial grounding on the concepts.

This workshop is very much designed for software engineers & developers with little or zero Kubernetes experience, but wish to get hands on and learn how to deploy and manage applications. It is not focused on the adminstration, network configuration & day-2 operations of Kubernetes itself, so some aspects may not be relevant to dedicated platform/infrastructure engineers.

The application used will be one that has already been written and built, so no application code will need to be written.

The workshop will use Azure Kubernetes Service (AKS) and assumes a relative degree of comfort in using Azure for sections 2 and 3.

Sections / modules:

- [⚒️ Workshop Pre Requisites](00-pre-reqs/readme.md) - Covering the pre set up and tools that will be needed.
- [🚦 Deploying Kubernetes](01-cluster/readme.md) - Deploying AKS, setting up kubectl and accessing the cluster.
- [📦 Container Registry & Images](02-container-registry/readme.md) - Deploying the registry and importing images.
- [❇️ Overview Of The Application](03-the-application/readme.md) - Details of the application to be deployed.
- [🚀 Deploying The Backend](04-deployment/readme.md) - Laying down the first two components and introduction to Deployments and Pods.
- [🌐 Basic Networking](05-network-basics/readme.md) - Introducing Services to provide network access.
- [💻 Adding The Frontend](06-frontend/readme.md) - Deploying the frontend to the app and wiring it up.
- [✨ Improving The Deployment](07-improvements/readme.md) - Recomended practices; resource limits, probes and secrets.
- [🌎 Helm & Ingress](08-helm-ingress/readme.md) - Finalizing the application architecture using ingress.

If you get stuck, the [GitHub repo for this workshop](https://github.com/benc-uk/kube-workshop) contains example and working files for most of the sections

## Optional Sections

These can be considered bonus sections, and are entirely optional. It is not expected that all these sections would be attempted, and they do not run in order.

- [🤯 Scaling, Stateful Workloads & Helm](09-extra-advanced/readme.md) - Scaling (manual & auto), stateful workloads and persitent volumes, plus more Helm.
- [🧩 Kustomize & GitOps](10-gitops-flux/readme.md) - Introduction to Kustomize and deploying apps through GitOps with Flux

## 📖 Extra Reading & Teach Yourself Exercises

A very brief list of potential topics and Kubernetes features you may want to look at after finishing:

#### Kubernetes Features:

- [Init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
- [Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Debugging Pods with shell access and exec](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/)
- Assigning Pods to Nodes with [selectors](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/) and [taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
- [Cluster Autoscaler in AKS](https://docs.microsoft.com/azure/aks/cluster-autoscaler)

#### Other Projects:

- Enable the [Kubernetes dashboard](https://github.com/kubernetes/dashboard)
- Enabling TLS with certificates from Let's Encrypt using [Cert Manager](https://cert-manager.io/docs/)
- Observability
  - With [Prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus) & [Grafana](https://artifacthub.io/packages/helm/grafana/grafana)
  - Using [AKS monitoring add-on](https://docs.microsoft.com/azure/azure-monitor/containers/container-insights-overview)
- Using [Dapr](https://dapr.io/) for building portable and reliable microservices
- Adding a service mesh such as [Linkerd](https://linkerd.io/) or [Open Service Mesh](https://docs.microsoft.com/azure/aks/open-service-mesh-about)
- Setting up the [Application Gateway Ingress Controller (AGIC)](https://docs.microsoft.com/azure/application-gateway/ingress-controller-overview)
