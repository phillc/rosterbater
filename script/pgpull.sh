#!/bin/bash

set -euxo pipefail

export POSTGRES_PASSWORD=$(kubectl get secret --namespace default rosterbater-postgresql -o jsonpath="{.data.postgresql-password}" | base64 --decode)

kubectl exec rosterbatercom-postgresql-0 -- bash -c "PGPASSWORD=$POSTGRES_PASSWORD pg_dump -Fc -U postgres rosterbater_production" > tmp/db/rosterbater.dump

docker-compose exec db sh -c "pg_restore --verbose --exit-on-error --no-acl --no-owner -h localhost -U postgres -d rosterbater_development --clean /var/lib/postgresql/data/rosterbater.dump"
