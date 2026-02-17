#!/bin/bash

DIR=$(dirname "$(readlink -f "$0")")
curl -Ssl https://kube-workshop.benco.io/08-more-improvements/nanomon_init.sql -o /tmp/nanomon_init.sql
kubectl create configmap nanomon-sql-init --from-file=/tmp/nanomon_init.sql
kubectl create secret generic database-creds --from-literal password='kindaSecret123!'

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30000 \
  --namespace ingress-nginx --create-namespace

kubectl apply --namespace default -f $DIR/