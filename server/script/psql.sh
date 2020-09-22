#!/bin/bash

set -euxo pipefail

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default rosterbater-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)

kubectl run rosterbatercom-postgresql-client \
    --rm \
    --tty \
    -i \
    --restart='Never' \
    --namespace default \
    --image docker.io/bitnami/postgresql:11.9.0-debian-10-r16 \
    --env="PGPASSWORD=$POSTGRES_PASSWORD" \
    --command \
    -- psql --host rosterbatercom-postgresql -U postgres -d postgres -p 5432
