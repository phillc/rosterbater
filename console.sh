#!/bin/sh -ex
POD=$(kubectl get pods -o jsonpath="{.items[0].metadata.name}")
kubectl exec -it $POD -- /bin/sh