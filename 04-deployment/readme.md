# 📦 Deploying The App - Part 1

We'll deploy the app piece by piece, and at first we'll deploy & configure things in a very sub-optimal way. This is in order to explore the Kubernetes concepts and show their purpose. Then we'll iterate and improve towards the final architecture.

We have three microservices we need to deploy, and due to dependencies between them we'll start with the MongoDB database then the data API and then finally move onto the frontend.

From here we will be creating and editing files, so it's worth creating a project folder locally (or even a git repo) in order to work from if you haven't done so already.

## 🍃 Deploying MongoDB

We'll apply configurations to Kubernetes using kubectl and YAML manifest files. These files will describe the objects we want to create, modify and delete in the cluster.

If you want to take this workshop slowly and research how to do this in order to build the required YAML yourself, you can use [the Kubernetes docs](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) and the following hints:

- `Deployment` should be used with a single replica.
- The image to be run is `mongo:latest`.
- The port **27017** should be exposed from the container.
- Do not worry about persistence or using a `Service` at this point.

Alternatively you can use the YAML below, don't worry this isn't cheating, in the real world nobody writes Kubernetes manifests from scratch 🙂

<details markdown="1">
<summary>Click here for the MongoDB deployment YAML</summary>

```yaml
kind: Deployment
apiVersion: apps/v1

metadata:
  name: mongodb

spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
        - name: mongodb-container

          image: mongo:latest
          imagePullPolicy: Always

          ports:
            - containerPort: 27017

          resources:
            limits:
              memory: "128Mi"
              cpu: "500m"
```

</details>

Paste this into a file `mongo-deployment.yaml` and then run:

```bash
kubectl apply -f mongo.deployment.yaml
```
  
If successful you will see `deployment.apps/mongodb created`, this will have created one `Deployment` and one `Pod`. You can check the status of your cluster with a few commands:

- `kubectl get deployment` - List the deployments, you should see 1/1 in ready status.
- `kubectl get pod` - List the pods, you should see one prefixed `mongodb-` with a status of *Running*
- `kubectl describe deploy mongodb` - Examine and get details of the deployment.
- `kubectl describe pod {podname}` - Examine the pod, you will need to get the name from the `get pod` command.
- `kubectl get all` - List everything; all pods, deployments etc.

Get used to these commands you will use them a LOT when working with Kubernetes.

```bash
kubectl describe pod --selector app=mongodb | grep ^IP:
```