Persistence
statefulsets

Helm again deploy everything

## 📈 Scaling

Scaling is a very common topic and is always required in some form to meet business demand, handle peak load and maintain application performance. There's fundamentally two approaches: manually scaling and using dynamic auto-scaling. Along side that there is both:

- **Horizonal scaling**: This is scaling the number of application _Pods_, within the limits of the resources available in the cluster.
- **Vertical or cluster scaling**: This is scaling the number of _Nodes_ in the cluster, and therefore the total resources available. We won't be looking at this.

Scaling stateless applications manually can be as simple as running the command to update the number of replicas in a _Deployment_, for example:

```bash
kubectl scale deployment data-api --replicas 4
```

Naturally this can also be done by updating the `replicas` field in the _Deployment_ manifest and applying it.

🧪 **Experiment**: Try scaling the data API to a large number of pods e.g. 50 or 60 to see what happens? If some of the _Pods_ remain in a "Pending" state can you find out the reason why? What effect does changing the resource requests (for example increasing the memory to 600Mi) have on this?

## 🚦 Autoscaling

Horizontal auto scaling is performed with the _Horizontal Pod Autoscaler_ which you can [read about here](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/). In essence it watches metrics emitted from the pods and other resources, and based on thresholds you set, it will modify the number of replicas dynamically.

To set up an _Horizontal Pod Autoscaler_ you can give it a deployment and some simple targets, as follows:

```bash
kubectl autoscale deployment data-api --cpu-percent=50 --min=2 --max=10
```

<details markdown="1">
<summary>This command is equivalent to deploying this HorizontalPodAutoscaler resource</summary>

```yaml
kind: HorizontalPodAutoscaler
apiVersion: autoscaling/v1
metadata:
  name: data-api
spec:
  maxReplicas: 10
  minReplicas: 2
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: data-api
  targetCPUUtilizationPercentage: 50
```

</details>

Run this in a separate terminal window to watch the status and number of pods:

```bash
watch -n 3 kubectl get pods
```

Now generate some fake load by hitting the `/api/info` endpoint with lots of requests. We use a tool called `hey` to do this easily and run 20 concurrent requests for 3 minutes

```bash
wget wget https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x hey_linux_amd64
./hey_linux_amd64 -z 180s -c 20 http://{INGRESS_IP}/api/info
```

After about 1~2 mins you should see new data-api pods being created. Once the `hey` command completes and the load stops, it will probably be around ~5 mins before the pods scale back down to their original number
