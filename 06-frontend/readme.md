# 💻 Adding The Frontend

We've ignored the frontend until this point, with the API and backend in place we are finally ready to deploy it. We need to use a *Deployment* and *Service* just as before. We can pick up the pace a little and setup everything we need in one go.

For the Deployment:

- The image needs to be `{ACR_NAME}.azurecr.io/smilr/frontend`.
- The port exposed from the container should be **3000**
- An environmental variable called `API_ENDPOINT` should be passed to the container, this needs to be a URL and should point to the external IP of the API from the previous part, as follows `http://{API_EXTERNAL_IP}/api`
- Label the pods with `app: frontend`

For the Service:

- The type of *Service* should be `LoadBalancer` same as the data API.
- The service port should be **80**
- The target port should be **3000**
- Use the label `app` and the value `frontend` for the selector

You might like to try creating the service before deploying the pods to see what happens. The YAML you can use for both, is provided below:

<details markdown="1">
<summary>Click here for the frontend deployment YAML</summary>

```yaml
kind: Deployment
apiVersion: apps/v1

metadata:
  name: frontend

spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend-container

          image: {ACR_NAME}.azurecr.io/smilr/frontend
          imagePullPolicy: Always

          ports:
            - containerPort: 3000

          env:
            - name: API_ENDPOINT
              value: http://{API_EXTERNAL_IP}/api
```

</details>


<details markdown="1">
<summary>Click here for the frontend service YAML</summary>

```yaml
kind: Service
apiVersion: v1

metadata:
  name: frontend

spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
```

</details>

As before, the there are changes that are required to the supplied YAML, replacing anything inside `{ }` with a corresponding real value. Save the two files `frontend-deployment.yaml` and `frontend-service.yaml`

