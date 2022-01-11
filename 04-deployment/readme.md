# Deploying The App - Part 1

We'll deploy the app piece by piece, and at first we'll deploy & configure things in a very sub-optimal way. This is in order to explore the Kubernetes concepts and show their purpose. Then we'll iterate and improve towards the final architecture

The first step is to deploy the MongoDB database. To do this a Kubernetes `Deployment` should be use to run a single `Pod` running a container from the `mongo:latest` image.

<details markdown="1">
<summary>Click here to expand the deployment YAML</summary>

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

Get the IP address of the new pod


XHXHXHXHXHXHX 
Man

```bash
kubectl describe pod --selector app=mongodb | grep ^IP:
```