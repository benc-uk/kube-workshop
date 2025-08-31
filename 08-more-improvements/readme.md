# ✨ The Path to Production Readiness

We're not done improving things yet! This section is a continuation of the previous one, where we will further enhance our deployment by adding a few more important features. Using configmaps and volumes, we'll continue stepping towards a more production-ready deployment.

Remember, back in the section 4 where we set up our Postgres database, we used a pre-built container image that automatically initialized the database & schema needed to run our application. This really was little more than a hacky workaround to get us up and running quickly, and in a real-world scenario, we should use the official Postgres image and inject the initialization script(s) at runtime. This is what we'll do in this section. This is a pattern you should adopt in your own applications, as baking in configuration and initialization data into your container images is not a good practice.

## 🗺️ ConfigMaps

A _ConfigMap_ in Kubernetes is an API object used to store non-confidential configuration data. ConfigMaps allow you to decouple configuration artifacts from image content to keep containerized applications portable. They can be used to store settings, scripts and entire configuration files. They are a little like _Secrets_, but are intended for non-sensitive data, and can be created from files.

In our case, we'll use a _ConfigMap_ to store the database initialization SQL script, which will be mounted into the Postgres container.

Getting the SQL script into the container is only half the battle, we also need to tell Postgres to run it when the container starts. The official Postgres image has a mechanism for this, where any `*.sql` or `*.sh` files found in the `/docker-entrypoint-initdb.d/` directory are automatically executed when the container is initialized. This is a great feature of the Postgres image, and one that we can leverage to achieve our goal.

## 💾 Volumes & Volume Mounts

A Volume in Kubernetes is a directory that is accessible to containers in a pod. Volumes are used to persist data, share data between containers, and manage configuration. There are [many types of volumes in Kubernetes](https://kubernetes.io/docs/concepts/storage/volumes/), when it comes to persisting data, there's a rabbit hole of options. For this section we'll

## 🖼️ Cluster & Architecture Diagram

Desptite the improvements we've made, the fundamental architecture of our deployment has not significantly changed beyond the addition of a _Secret_ resource, so we'll skip the diagram this time.

## 🔍 Reference Manifests

If you get stuck and are looking for working manifests you can refer to, they are available here:

- [worker-deployment.yaml](worker-deployment.yaml)
- [postgres-deployment.yaml](postgres-deployment.yaml)

## Navigation

[Return to Main Index 🏠](../readme.md) ‖
[Previous Section ⏪](../07-frontend/readme.md) ‖ [Next Section ⏩](../09-helm-ingress/readme.md)
