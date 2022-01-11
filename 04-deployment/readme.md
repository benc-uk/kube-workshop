# Deploying The App - Part 1

<details>
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

Blah
sadasda

sdsafas


```bash
kubectl describe pod --selector app=mongodb | grep ^IP:
```