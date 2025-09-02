---
tags: extra
index: 10
title: Scaling & Stateful Workloads
summary: Scaling (manual & auto), stateful workloads, persitent volumes, plus more Helm.
layout: default.njk
icon: 🤯
---

# 🤯 Scaling, Stateful Workloads & Helm

This final section touches on some slightly more advanced and optional concepts we've skipped over. They aren't required
to get a basic app up & running, but generally come up in practice and real world use of Kubernetes.

Feel free to do as much or as little of this section as you wish.

## 📈 Scaling

Scaling is a very common topic and is always required in some form to meet business demand, handle peak load and
maintain application performance. There's fundamentally two approaches: manually scaling and using dynamic auto-scaling.
Along side that there are two dimensions to consider:

- **Horizontal scaling**: This is scaling the number of application _Pods_, within the limits of the resources available
  in the cluster.
- **Vertical or cluster scaling**: This is scaling the number of _Nodes_ in the cluster, and therefore the total
  resources available. We won't be looking at this here, but you can
  [read the docs](https://docs.microsoft.com/en-us/azure/aks/cluster-autoscaler) if you want to know more.

Scaling stateless applications manually can be as simple as running the command to update the number of replicas in a
_Deployment_, for example:

```bash
kubectl scale deployment nanomon-api --replicas 4
```

Intuitively this same result can also be done by updating the `replicas` field in the _Deployment_ manifest and applying
it.

🧪 **Experiment**: Try scaling the API to a large number of pods e.g. 50 or 60 to see what happens? If some of the
_Pods_ remain in a "Pending" state can you find out the reason why? What effect does changing the resource requests (for
example increasing the memory to 600Mi) have on this?

## 🚦 Autoscaling

Horizontal auto scaling is performed with the _Horizontal Pod Autoscaler_ which you can can read about in the docs, link
below. In essence it watches metrics emitted from the pods and other resources, and based on thresholds you set, it will
modify the number of replicas dynamically.

[📚 Kubernetes Docs: Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

To set up an _Horizontal Pod Autoscaler_ you can give it a deployment and some simple targets, as follows:

```bash
kubectl autoscale deployment nanomon-api --cpu="50%" --min=2 --max=10
```

<details markdown="1">
<summary>This command is equivalent to deploying this HorizontalPodAutoscaler resource</summary>

```yaml
kind: HorizontalPodAutoscaler
apiVersion: autoscaling/v1
metadata:
  name: nanomon-api
spec:
  maxReplicas: 10
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nanomon-api
  targetCPUUtilizationPercentage: 50
```

</details>

Run this in a separate terminal window to watch the resource usage and number of API pods:

```bash
watch -n 5 kubectl top pods
```

Now to generate some fake load by hitting the `/api/info` endpoint with lots of requests. We can use a tool called `hey`
to do this easily and run 20 concurrent requests for 3 minutes. This doesn't sound like much but the tool runs them as
fast as possible, so it will result in quite a lot of requests.

```bash
wget https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x hey_linux_amd64
./hey_linux_amd64 -z 180s -c 20 http://{EXTERNAL_INGRESS_IP}/api/status
```

After about 1~2 mins you should see new API pods being created. Once the `hey` command completes and the load stops, it
will probably be around ~5 mins before the pods scale back down to their original number. The command
`kubectl describe hpa` is useful and will show you the current status of the autoscaler.

## 🛢️ Improving The PostgreSQL Backend

There's two very major problems with our backend database:

- There's only a single instance, i.e. one Pod, introducing a serious single point of failure.
- The data held by the PostgreSQL _Pod_ is ephemeral and if the _Pod_ was terminated for any reason, we'd lose all
  application data. Not very good!

We can't simply horizontally scale out the PostgreSQL _Deployment_ with multiple _Pod_ replicas as it is stateful, i.e.
it holds data and state. We'd create a "split brain" situation as requests are routed to different Pods each with their
own copy of the data, and they would quickly diverge.

Kubernetes does provide a [feature](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/) called
_StatefulSets_ which greatly helps with the complexities of running multiple stateful services across in a cluster.

⚠️ But wait _StatefulSets_ are not a magic wand! Any stateful workload such as a database **still needs to be made
aware** it is running in multiple places and handle the data synchronization/replication. This can be setup for
PostgreSQL, but is deemed too complex for this workshop.

However we can address the issue of data persistence.

🧪 **Optional Experiment**: Try using the app and adding a monitor, then run `kubectl delete pod {postgres-pod-name}`
You will see that Kubernetes immediately restarts it. However when the app recovers and reconnects to the DB (which
might take a few seconds), you will see the data you created is gone.

To resolve the data persistence issues, we need do three things:

- Change the PostgreSQL _Deployment_ to a _StatefulSet_ with a single replica.
- Add a `volumeMount` to the container mapped to the `/var/lib/postgresql/data` path filesystem, which is where
  PostgreSQL stores its data. Note, you must not use the `subPath: data` attribute here.
- Add a `volumeClaimTemplate` to dynamically create a _PersistentVolume_ and a _PersistentVolumeClaim_ for this
  _StatefulSet_. Use the "default" _StorageClass_ and request a 500M volume which is dedicated with the "ReadWriteOnce"
  access mode.

The relationships between these in AKS and Azure, can be explained with a diagram:

![persistent volume claims](https://docs.microsoft.com/azure/aks/media/concepts-storage/persistent-volume-claims.png)

_PersistentVolumes_, _PersistentVolumeClaims_, _StorageClasses_, etc. are a deep and complex topics in Kubernetes, if
you want begin reading about them there are masses of information in
[the docs](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). However it is suggested for now simply take
the YAML below:

<details markdown="1">
<summary>Completed PostgreSQL <i>StatefulSet</i> YAML manifest</summary>

```yaml
apiVersion: apps/v1
kind: StatefulSet

metadata:
  name: postgres

spec:
  serviceName: postgres
  replicas: 1
  selector:
    matchLabels:
      app: postgres

  volumeClaimTemplates:
    - metadata:
        name: postgres-pvc
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: default
        resources:
          requests:
            storage: 500M

  template:
    metadata:
      labels:
        app: postgres

    spec:
      volumes:
        - name: initdb-vol
          configMap:
            name: nanomon-sql-init

      containers:
        - name: postgres
          image: postgres:17

          ports:
            - containerPort: 5432

          env:
            - name: POSTGRES_DB
              value: "nanomon"
            - name: POSTGRES_USER
              value: "nanomon"
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: database-creds
                  key: password

          resources:
            requests:
              cpu: 50m
              memory: 100Mi
            limits:
              cpu: 100m
              memory: 512Mi

          readinessProbe:
            exec:
              command: ["pg_isready", "-U", "nanomon"]
            initialDelaySeconds: 5
            periodSeconds: 10

          volumeMounts:
            - name: initdb-vol
              mountPath: /docker-entrypoint-initdb.d
              readOnly: true
            - name: postgres-pvc
              mountPath: /var/lib/postgresql/data
              subPath: data
```

</details>

Save as `postgres-statefulset.yaml` remove the old deployment with `kubectl delete deployment postgres` and apply the
new `postgres-statefulset.yaml` file. Some comments:

- When you run `kubectl get pods` you will see the pod name ends `-0` rather than the random hash, this is because
  _StatefulSet_ pods are given a stable network identity.
- Running `kubectl get pv,pvc` you will see the new _PersistentVolume_ and _PersistentVolumeClaim_ that have been
  created. The _Pod_ might take a little while to start while the volume is created, and is "bound" to the _Pod_

If you repeat the pod deletion experiment above, you should see that the data is maintained after you delete the
`postgres-0` pod and it restarts.

## 💥 Installing The App with Helm

The NanoMon app we have been working with, comes provided with a Helm chart, which you can take a look at here,
[NanoMon Helm Chart](https://github.com/benc-uk/nanomon/tree/master/deploy/helm/nanomon).

With this we can deploy the entire app, all the deployments, pods, services, ingress, etc. with a single command.
Naturally if we were to have done this from the beginning there wouldn't have been much scope for learning!

However as this is the final section, now might be a good time to try it. Due to some limitations (mainly the lack of
public DNS), only one deployment of the app can function at any given time. So you will need to remove what have
currently deployed, by running:

```bash
kubectl delete deploy,sts,svc,ingress,hpa --all
```

Add the Helm remote repo where the NanoMon chart is located and update your Helm repo cache:

```bash
helm repo add nanomon 'https://raw.githubusercontent.com/benc-uk/nanomon/main/deploy/helm'
helm repo update nanomon
```

Helm supports passing in values to the chart to override defaults. Charts can often expose hundreds of parameters, with
complex types, so you can store your parameters in a YAML values file. To deploy NanoMon into your cluster, place the
contents below into a `values.yaml` file, replacing `__ACR_NAME__` with your Azure Container Registry name:

```yaml
ingress:
  enabled: true
image:
  regRepo: "__ACR_NAME__.azurecr.io"
```

Now to deploy the app with Helm, run the command below:

```bash
helm install demo nanomon/nanomon --values values.yaml
```

Validate the deployment as before with `helm` and `kubectl` and check you can access the app in the browser using the
same ingress IP address as before.
