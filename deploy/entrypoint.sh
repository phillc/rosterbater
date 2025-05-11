#!/bin/sh
set -e

if [ -f tmp/pids/server.pid ]; then
    rm tmp/pids/server.pid
fi

echo "Running RAILS_ENV=$RAILS_ENV $@"

exec "$@"

