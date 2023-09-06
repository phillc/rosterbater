#!/bin/sh -ex
docker buildx build --platform linux/amd64 -t mrphillc/rosterbater:latest server
docker push mrphillc/rosterbater:latest
kubectl create -f kube/migrate.yml
kubectl wait --for=condition=complete --timeout=600s job/migrate
kubectl delete job migrate
kubectl rollout restart deployment/rosterbater-deployment
# kubectl rollout restart deployment/sidekiq
