# 💻 Adding The Frontend

We've ignored the frontend until this point, with the API and backend in place we are ready to deploy it. We can use a *Deployment* and *Service* just as before. We can pick up the pace a little and setup everything we need in one go.

For the Deployment:

- The image needs to be `${ACR_NAME}.azurecr.io/smilr/frontend`.
- The port exposed from the container should be **3000**
- An environmental variable called `API_ENDPOINT` should be passed to the container, this needs to be a URL and should point to the external IP of the API from the previous part, as follows `http://{data-api-external-ip}/api`
- Label the pods with `app: frontend`

For the Service:

- The type of `Service` should be `LoadBalancer` same as the data API.
- The service port should be **80**
- The target port should be **3000**
- Selector decides what pods are behind the service, in this case use the label `app` and the value `frontend`

You mght like to try creating the service before deploying the pods to see what happens