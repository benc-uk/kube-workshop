# 🌐 Basic Networking

Pods are both ephemeral and "mortal", they should be considered effectively transient. Kubernetes can terminate and reschedule pods for a range of reasons, including rolling updates, scaling up & down and other cluster operations.

Kubernetes solves this with **Services**, which act as a network abstraction over a group of pods, and have their own lifecycle. We can use them to greatly improve what we've deployed

Put a service in front of the MongoDB pods, if you want to create the service YAMl yourself, you can [refer to the Kubernetes docs](https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service)

- The type of `Service` should be `ClusterIP` which means it's internal to the cluster only
- The service port should be 27017
- The target port should be 27017
- Selector decides what pods are behind the service, in this case use the label `app` and the value `mongodb`

> 📝 NOTE: Labels are metadata that can be added to any object in Kubernetes, they are simply key-value pairs. The label "app" is commonly used, but has no special meaning, and isn't used by Kubernetes in any way

A completed YAML manifest for the service is given below:

<details markdown="1">
<summary>Click here for the MongoDB service YAML</summary>

```yaml
kind: Service
apiVersion: v1

metadata:
  name: database

spec:
  type: ClusterIP  
  selector:
    app: mongodb
  ports:
    - protocol: TCP
      port: 27017
      targetPort: 27017
```

</details>