# Kubernetes Workshop

This is a hands-on, technical workshop intended to get comfortable working with Kubernetes and deploying & configuring applications. It should hopefully take roughly 5~6 hours. This workshop is intended partial as a companion to this [Kubernetes Technical Primer](https://github.com/benc-uk/kube-primer) which can be read or used to get an initial grounding on the concepts.

This workshop is very much designed for software engineers & developers with little or zero Kubernetes experience, but wish to get hands on and learn how to deploy and manage applications. It is not focused on the management, network configuration & day-2 operations of Kubernetes so some aspect may not be relevant to dedicated platform/infrastructure engineers.

The application will be one that has already been designed, written and built, so no application code will need to be written. 

The workshop will use Azure Kubernetes Service (AKS) and assumes a relative degree of comfort in using Azure.

Sections:

- [⚒️ Workshop Pre Requisites](00-pre-reqs/readme.md) - Covering the pre set up and tools that will be needed.
- [🚦 Deploying Kubernetes](01-cluster/readme.md) - Deploying AKS, setting up kubectl and accessing the cluster.
- [📦 Container Registry & Images](02-container-registry/readme.md) - Deploying the registry and importing images.
- [❇️ Overview Of The Application](03-the-application/readme.md) - Details of the application to be deployed.
- [🚀 Deploying The Backend](04-deployment/readme.md) - Laying down the first two components and introduction to Deployments and Pods.
- [🌐 Basic Networking](05-network-basics/readme.md) - Introducing Services to provide network access.
- [💻 Adding The Frontend](06-frontend/readme.md) - Deploying the frontend to the app and wiring it up.
