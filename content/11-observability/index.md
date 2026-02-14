---
tags: extra
index: 11
title: Observability & Monitoring
summary:
  Learn how to monitor and observe your Kubernetes cluster and applications using tools like Prometheus and Grafana.
layout: default.njk
icon: 📊
---

# {{ icon }} {{ title }}

In this section, which is completely optional, you'll learn about observability and monitoring in Kubernetes. We'll
cover how to set up Prometheus and Grafana to collect and visualize metrics from your cluster and applications. These
tools are not part of the core Kubernetes platform, but are widely used in the ecosystem for monitoring and
observability.

## 🔥 What Is Prometheus?

Prometheus is an open-source monitoring and alerting toolkit, originally built at SoundCloud and now a graduated project
of the Cloud Native Computing Foundation (CNCF). It has become the de-facto standard for monitoring Kubernetes clusters
and the workloads running on them.

[📚 Prometheus Docs: Overview](https://prometheus.io/docs/introduction/overview/)

Key concepts to understand:

- **Pull-based model**: Unlike traditional monitoring systems that rely on agents pushing data, Prometheus _scrapes_
  (pulls) metrics from HTTP endpoints exposed by your applications and infrastructure. This is a fundamentally different
  approach that simplifies configuration and discovery.
- **Time-series data**: All data is stored as time-series, identified by a metric name and a set of key-value labels.
  For example `http_requests_total{method="GET", status="200"}` is a time series tracking HTTP GET requests with a 200
  status code.
- **PromQL**: Prometheus has its own powerful query language called PromQL, used to select and aggregate time-series
  data. It's used for building dashboards, alerts, and ad-hoc queries.
- **Service discovery**: Prometheus integrates with Kubernetes natively and can automatically discover pods, services,
  and nodes to scrape, without you needing to manually configure each target.

In a Kubernetes context, many components already expose metrics in a Prometheus-compatible format out of the box,
including the Kubernetes API server, kubelet, kube-state-metrics, and more. This means you get a wealth of cluster-level
metrics with very little effort.

## 🚀 Installing Prometheus With Helm

We'll use Helm (which we introduced back in section 9 - [link here](../09-helm-ingress) to install the
[kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).
This is a popular community Helm chart that bundles together:

- **Prometheus** — the metrics collection and storage engine
- **Grafana** — a powerful dashboarding and visualization tool
- **Alertmanager** — handles routing and managing alerts
- **kube-state-metrics** — exposes metrics about the state of Kubernetes objects
- **node-exporter** — exposes hardware and OS-level metrics from each node

This "batteries included" approach saves a lot of setup time and is widely used in production clusters.

First, add the Helm chart repository and update:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update
```

Create a namespace for the monitoring stack:

```bash
kubectl create namespace monitoring
```

Now install the chart. We'll pass a few values to make it easier to access Prometheus and Grafana during this workshop:

```bash
helm install kube-mon prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=workshopAdmin \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

> The two `NilUsesHelmValues` settings tell Prometheus to discover _all_ ServiceMonitors and PodMonitors in the cluster,
> not just those created by this Helm release. This makes it much easier to add monitoring for your own applications
> later.

This will take a minute or two to get everything up and running. Check the status of the pods:

```bash
kubectl get pods -n monitoring
```

You should see several pods spinning up, including Prometheus, Grafana, Alertmanager, kube-state-metrics, and
node-exporter pods. Wait until all pods show `Running` and are ready.

## 🔎 Exploring The Prometheus UI

Prometheus has a built-in web UI that lets you run queries and explore metrics. To access it, we'll use
`kubectl port-forward` to create a local tunnel to the Prometheus service:

```bash
kubectl port-forward -n monitoring svc/kube-mon-kube-prometheus-s-prometheus 9090:9090
```

> Leave this running in a terminal and open a new terminal for further commands. If the service name doesn't match, you
> can find the correct name with `kubectl get svc -n monitoring | grep prometheus`

Now open your browser and navigate to `http://localhost:9090`. You should see the Prometheus web interface.

Let's try a few PromQL queries to explore what's available. Paste these into the query box and click "Execute":

**Number of running pods per namespace:**

```promql
count by (namespace) (kube_pod_status_phase{phase="Running"})
```

**CPU usage across all nodes:**

```promql
rate(node_cpu_seconds_total{mode!="idle"}[5m])
```

**Total memory usage as a percentage per node:**

```promql
100 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100)
```

🧪 **Experiment**: Click on the "Graph" tab after running a query to see a time-series visualization. Try changing the
time range to see how metrics have changed since you deployed the monitoring stack.

You can also explore the "Status > Targets" page to see all of the endpoints Prometheus is currently scraping. You
should see your Kubernetes components (API server, kubelet, etc.) listed as active targets.

## 📊 Grafana Dashboards

While the Prometheus UI is great for ad-hoc queries, Grafana is where you'll spend most of your time when it comes to
visualizing metrics. The kube-prometheus-stack chart comes pre-loaded with a rich set of dashboards for monitoring your
cluster.

Set up port forwarding to Grafana:

```bash
kubectl port-forward -n monitoring svc/kube-mon-grafana 3000:80
```

Open `http://localhost:3000` in your browser and log in with:

- **Username**: `admin`
- **Password**: `workshopAdmin`

Once logged in, click on the hamburger menu (☰) and navigate to **Dashboards**. You'll find a collection of
pre-installed dashboards organized into folders. Some highlights worth exploring:

- **Kubernetes / Compute Resources / Cluster** — A high-level overview of CPU and memory usage across your entire
  cluster.
- **Kubernetes / Compute Resources / Namespace (Pods)** — Drill into a specific namespace to see resource usage per pod.
  Try selecting the `default` namespace to see your NanoMon application pods.
- **Kubernetes / Networking / Cluster** — Network traffic and bandwidth metrics across your cluster.
- **Node Exporter / Nodes** — Hardware-level metrics from your cluster nodes: CPU, memory, disk, and network.

🧪 **Experiment**: Open the "Kubernetes / Compute Resources / Namespace (Pods)" dashboard and select the `default`
namespace. Can you identify your NanoMon API pods? What does their CPU and memory usage look like?

## 💾 Data Sources

How does Grafana know where to get the metrics from? In Grafana, you configure "data sources" that tell it how to
connect to sources of data. In our case, we have a Prometheus data source that points to the Prometheus instance we
installed. This was automatically set up for us by the Helm chart, but it's useful to understand how it works.

To see the data source configuration, open the side menu (☰) and go to **Configuration > Data Sources**. Click on the
"Prometheus" data source to see its settings. The URL should be set to
`http://kube-mon-kube-prometheus-s-prometheus.monitoring.svc:9090`, which is the internal address of the Prometheus
service within the cluster. This allows Grafana to query Prometheus directly from within the cluster.

## 👀 Creating Custom Dashboards

The pre-installed dashboards are great for general cluster monitoring, but one of the most powerful features of Grafana
is the ability to create your own custom dashboards. This allows you to visualize the specific metrics that are most
relevant to your applications and use cases.

Let's build a simple dashboard that shows network traffic flowing into the NanoMon API pods.

1. Click on the "+" icon in the side menu and select **Dashboard**.
2. Click **Add visualization** and choose **Prometheus** as the data source.
3. In the query editor at the bottom, switch to the "Code" mode (toggle in the top-right of the query editor) and enter
   the following PromQL query:

```promql
rate(container_network_receive_bytes_total{namespace="default", pod=~".*api.*"}[5m])
```

This query uses `container_network_receive_bytes_total`, a metric that is already being collected for every container in
the cluster. It calculates the per-second rate (which is what the `rate()` function does) of bytes received by pods
matching `.*api.*` in the `default` namespace over a 5-minute window.

4. In the panel options on the right sidebar:
   - Set the **Title** to something like "NanoMon API Network Traffic".
   - Under **Graph styles**, ensure the **Style** is set to "Lines" for a time-series line graph.
5. Click **Apply** in the top-right to save the panel.

You should now see a line graph showing the rate of network traffic into your API pods. Generate some traffic by
visiting the NanoMon frontend and clicking around to see the graph respond.

You can continue adding more panels to the dashboard — try adding panels for CPU or memory usage per pod. When you're
done, click the 💾 save icon at the top of the dashboard and give it a name.

🧪 **Experiment**: Try adding a second panel with the query
`rate(container_cpu_usage_seconds_total{namespace="default", pod=~".*api.*"}[5m])` to track CPU usage of the API pods
alongside network traffic.

Also try changing the visualization type (it's in the top right when editing a panel) to a bar graph or gauge to see how
it looks. Grafana's flexibility allows you to create dashboards that are tailored to your specific monitoring needs.

## 🧹 Cleaning Up

The monitoring stack uses a fair amount of resources. If you want to remove it to free up cluster resources:

```bash
helm uninstall kube-mon --namespace monitoring
kubectl delete namespace monitoring
```

> Note: Helm uninstall won't remove the CRDs (Custom Resource Definitions) that were created. These are harmless but if
> you want a completely clean cluster you can remove them with
> `kubectl delete crd -l app.kubernetes.io/part-of=kube-prometheus-stack`
