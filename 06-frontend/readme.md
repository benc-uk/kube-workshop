# 💻 Adding The Frontend

We've ignored the frontend until this point, with the API and DB in place we are finally ready to deploy it.
We need to use a _Deployment_ and _Service_ just as before (you might be starting to see a pattern!). We can
pick up the pace a little and setup everything we need in one go.

For the Deployment:

- The image needs to be `{ACR_NAME}.azurecr.io/nanomon/frontend:latest`.
- The port exposed from the container should be **8001**.
- An environmental variable called `API_ENDPOINT` should be passed to the container, this needs to be a URL and should point to the external IP of the API from the previous part, as follows `http://{API_EXTERNAL_IP}/api`.
- Label the pods with `app: nanomon-frontend`.

For the Service:

- The type of _Service_ should be `LoadBalancer` same as the data API.
- The service port should be **80**.
- The target port should be **8001**.
- Use the label `app` and the value `nanomon-frontend` for the selector.

You might like to try creating the service before deploying the pods to see what happens.
The YAML you can use for both, is provided below:

`frontend-deployment.yaml`:

<details markdown="1">
<summary>Click here for the frontend deployment YAML</summary>

```yaml
kind: Deployment
apiVersion: apps/v1

metadata:
  name: nanomon-frontend

spec:
  replicas: 1
  selector:
    matchLabels:
      app: nanomon-frontend
  template:
    metadata:
      labels:
        app: nanomon-frontend
    spec:
      containers:
        - name: frontend-container

          image: {ACR_NAME}.azurecr.io/nanomon/frontend:latest
          imagePullPolicy: Always

          ports:
            - containerPort: 8001

          env:
            - name: API_ENDPOINT
              value: http://{API_EXTERNAL_IP}/api
```

</details>

`frontend-service.yaml`:

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
    app: nanomon-frontend
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8001
```

</details>

As before, the there are changes that are required to the supplied YAML, do not try to use it as-is, instead replace anything inside `{ }` with a corresponding real value.

## 💡 Accessing and Using the App

Once the two YAMLs have been applied:

- Check the external IP for the frontend is assigned with `kubectl get svc frontend`.
- Once it is there, go to that IP in your browser, e.g. `http://{FRONTEND_IP}/` - the application should load and the NanoMon frontend is shown.

If you want to spend a few minutes using the app, you can click on "New" and create a new monitor, click on the "HTTP" button to create a default HTTP monitor, pointing at http://example.net for example. Then click "Create" and you should see the monitor appear in the main view. It will remain in a grey "Unknown" status until we deploy the runner in a later section. But the fact that the monitor appears shows that the frontend is able to communicate with the API and the API with the database.

## 🖼️ Cluster & Architecture Diagram

The resources deployed into the cluster & in Azure at this stage can be visualized as follows:

![architecture diagram](./diagram.png)

Notice we have **two public IPs**, the `LoadBalancer` service type is not an instruction to Azure to deploy an entire Azure Load Balancer.
Instead it's used to create a new public IP and assign it to the single Azure Load Balancer (created by AKS) that sits in front of the cluster.
We'll refine this later when we look at setting up an ingress.

## Navigation

[Return to Main Index 🏠](../readme.md) ‖
[Previous Section ⏪](../05-network-basics/readme.md) ‖ [Next Section ⏩](../07-improvements/readme.md)
