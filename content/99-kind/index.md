---
tags: ignore
index: 99
title: Using Kind instead of Azure Kubernetes Service
summary: This page provides notes and modifications for using Kind for this workshop, instead of AKS
layout: default.njk
icon: 📌
---

# {{ icon }} {{ title }}

## Introduction

If you don't have access to a cloud environment or prefer to do your development and testing locally, you can use
[Kind (Kubernetes IN Docker)](https://kind.sigs.k8s.io/) to create a local Kubernetes cluster. Kind runs Kubernetes
clusters in Docker containers, making it an excellent tool for local development and testing. However there are some
differences and modifications needed when using Kind compared to a cloud-based Kubernetes cluster, especially in the
context of this workshop. Rather than add a lot of specific instructions to the main workshop content, this page
provides notes and modifications for using Kind as a local Kubernetes cluster for development and testing.

## Setup and Usage

The installation of Kind is straightforward, and the documentation is quite good. However, there are a few things to
keep in mind when using Kind for local Kubernetes development.

1. See [Kind's official documentation](https://kind.sigs.k8s.io/) for installation instructions and usage details. You
   will need Docker or Podman installed and set up on your machine before you begin.
1. When creating a Kind cluster, you will need to specify port mappings to access your services from outside the
   cluster. Create a YAML file (e.g., `kind-config.yaml`) with the following content:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  # NodePorts to allow external access
  - role: control-plane
    extraPortMappings:
      - containerPort: 30000
        hostPort: 30000
        protocol: TCP
      - containerPort: 30001
        hostPort: 30001
        protocol: TCP
  # Three worker nodes, these aren't real nodes!
  - role: worker
  - role: worker
  - role: worker
```

1.Then create the cluster using this configuration:

```bash
kind create cluster --config kind-config.yaml
```

This should create a Kind cluster with the specified port mappings, allowing you to access services on ports 30000,
30001, and 30002 from your host machine.

## Workshop Modifications

If you want to use Kind for this workshop, there are a few modifications you will need to make to the instructions and
manifests. We'll not provision any resources in the cloud or Azure so some of the steps will be skipped, and some of the
manifests will need to be modified to work with Kind.

### General Modifications

We will not use our own container registry, so for any image references in the manifests we'll use the public images
published on GitHub Container Registry instead of the ones from Azure Container Registry, as follows:

- API: `ghcr.io/benc-uk/nanomon-api:latest`
- Frontend: `ghcr.io/benc-uk/nanomon-frontend:latest`
- Runner: `ghcr.io/benc-uk/nanomon-runner:latest`
- Preconfigured PostgreSQL: `ghcr.io/benc-uk/nanomon-postgres:latest`

### Section 01 & 02 - Cluster and Registry Setup

Skip these sections as we won't be provisioning any resources in the cloud or Azure. Instead, we'll create a local Kind
cluster and use public images from GitHub Container Registry.

### Section 05 - Network Basics

External load balancers are hard to get working in Kind, so instead of using a `LoadBalancer` service type for the API,
we will use `NodePort` and access it via localhost and the mapped port.

> What is a `NodePort` type of _Service_? A `NodePort` service exposes the service on a static port on each node in the
> cluster. This means that you can access the service from outside the cluster by sending requests to any node's IP
> address and the specified `NodePort`. When working in the cloud you rarely if ever use `NodePort` services, but in a
> local development environment like Kind, it's a common way to access services running in the cluster.

When creating the _Service_ for the API, modify the manifest to use `NodePort` instead of `LoadBalancer`, and specify a
port that matches the port mapping we set up in the Kind cluster configuration (e.g., 30000):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: api
spec:
  type: NodePort
  selector:
    app: nanomon-api
  ports:
    - protocol: TCP
      port: 8000
      targetPort: 8000
      nodePort: 30000
```

### Section 06 - Frontend Deployment

When deploying the frontend, do the same thing as with the API, use `NodePort` instead of `LoadBalancer` and specify a
different port that matches the port mapping in the Kind cluster configuration (e.g., 30001):

```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: NodePort
  selector:
    app: nanomon-frontend
  ports:
    - protocol: TCP
      port: 8001
      targetPort: 8001
      nodePort: 30001
```

- Instead of using `__API_EXTERNAL_IP__` in the frontend configuration, you use `localhost:30000` to access the API from
  the frontend.
- Instead of using an external IP address to access the frontend, you can access it at `http://localhost:30001` from
  your host machine.

### Section 09 - Ingress

- When deploying Nginx Ingress Controller, you can still use Helm but we need to use a `NodePort` _Service_ instead of
  `LoadBalancer`, and we won't have an external IP address. Instead, we'll access the ingress controller using
  `localhost` and the assigned `NodePort`.

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30000 \
  --namespace ingress
```

### Section 09a - Gateway API

- Be sure delete the API and frontend services created in previous sections, before creating the Gateway API resources,
  as they will conflict with the Gateway API controller's own services. `kubectl delete svc api frontend -n default`
  should do the trick.
- When deploying the Gateway API controller, we will use a `NodePort` _Service_ and access it via `localhost` and the
  assigned `NodePort`. Note we use the same `NodePort` values as we did in sections 05 and 06 which is why we need to
  delete the previous services, otherwise there will be conflicts.

```bash
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --namespace nginx-gateway \
  --set nginx.service.type=NodePort \
  --set-json 'nginx.service.nodePorts=[{"port":30000,"listenerPort":80}, {"port":30001,"listenerPort":8443}]'
```

- You can now recreate the _Service_'s for the API and frontend as `ClusterIP` type, as described in 'Reconfiguring The
  App'

### Section 10 - Extra Advanced

The part on persisting data with Azure Disk won't be relevant for Kind, but you can still use a `PersistentVolume` and
`PersistentVolumeClaim` with a local storage class.

The only difference is that instead of using `default` storage class, you will need to use `standard`,so in the
StatefulSet manifest for PostgreSQL, modify the `storageClassName` to `standard`

### Section 11 - Observability

No modification is needed for this section, and surprisingly the kube-prometheus-stack can be deployed in Kind without
problem

### Section 12 - CI/CD with GitHub Actions

Getting GitHub Actions to deploy to a local Kind cluster is clearly a non-starter, you will not be able to fdo much with
this section. However, you can still build and push your images to GitHub Container Registry, and deploy them to

### Section 13 - GitOps & Flux

The section on Kustomize can be followed, however installation and use of Flux is not really feasible in a local Kind
cluster, so you can skip that part.

### Section 14 - Nodes

Kind runs Kubernetes clusters in Docker containers, so you won't have access to the underlying nodes in the same way you
would with a cloud-based Kubernetes cluster. However, you can still play with labelling nodes
