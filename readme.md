# Mini Kubernetes Workshop

This is a technical, hands-on workshop intended to get people comfortable in working with Kubernetes and deploying applications. It should hopefully take roughly 5~6 hours. This workshop is somewhat intended as a companion to my [Kubernetes Technical Primer](https://github.com/benc-uk/kube-primer) which can be read or used to get an initial grounding on the concepts. 

This workshop is very much designed for beginners with little or zero Kubernetes experience who wish to get hands on and learn how to deploy and manage applications.

The application will be one that has already been designed, written and built, so no application code will need to be written. 

The workshop will use Azure Kubernetes Service (AKS) and assumes a relative degree of comfort in using Azure.

Sections:

- [⚒️ Workshop Pre Requisites](00-pre-reqs/readme.md) - Covering the pre set up and tools that will be needed.
- [🚦 Deploying Kubernetes](01-cluster/readme.md) - Deploying AKS, setting up kubectl and accessing the cluster.
- [📦 Container Registry & Images](02-container-registry/readme.md) - Deploying the registry and importing images.
- [❇️ Overview Of The Application](03-the-application/readme.md) - Details of the application to be deployed.
- [🚀 Deploying The App - Part 1](04-deployment/readme.md) - Laying down the first two components and introduction to Deployments and Pods.
- [🌐 Basic Networking](05-network-basics/readme.md) - Introducing Services to provide network access.
