# Archived Section: K3S

This section is part of the archived Kube Workshop repository, and is no longer actively maintained. It is kept here for reference purposes only, it might be out of date and has not been tested recently.

## Single node K3S cluster on a VM

In this path you'll learn to use Kubernetes as if you were running it on a on-premises machine, including configuring the computer with the required set up manually.

Sections / modules:

- [⚒️ Workshop Pre Requisites](00-pre-reqs/readme.md) - Covering the pre set up and tools that
  will be needed.
- [🚦 Deploying Kubernetes](01-cluster/readme.md) - Deploying the VM, setting up kubectl and accessing
  the cluster.
- [📦 Container Registry & Images](02-container-registry/readme.md) - Deploying the registry and
  importing images.
- [❇️ Overview Of The Application](03-the-application/readme.md) - Details of the application to be
  deployed.
- [🚀 Deploying The Backend](04-deployment/readme.md) - Laying down the first two components and
  introduction to Deployments and Pods.
- [🌐 Basic Networking](05-network-basics/readme.md) - Introducing Services to provide network
  access.
- [💻 Adding The Frontend](06-frontend/readme.md) - Deploying the frontend to the app and wiring
  it up.
- [✨ Improving The Deployment](07-improvements/readme.md) - Recommended practices; resource
  limits, probes and secrets.
- [🌎 Ingress](08-ingress/readme.md) - Finalizing the application architecture using ingress.

All of the Kubernetes concepts & APIs explored and used are not specific to AKS, K3S or Azure.

## 🍵 K3s Optional Sections

These can be considered bonus sections, and are entirely optional. It is not expected that all these sections would be attempted, and they do not run in order.

- [🤯 Scaling, Stateful Workloads & Helm](09-extra-advanced/readme.md) - Scaling (manual & auto),
  stateful workloads and persitent volumes, plus more Helm.
- [🧩 Kustomize & GitOps](10-gitops-flux/readme.md) - Introduction to Kustomize and deploying apps
  through GitOps with Flux.
- [👷 CI/CD with Kubernetes](/11-cicd-actions/readme.md) - How to manage CI/CD pipelines using Github
  Actions
