#!/usr/bin/env bash

set -e

if [ -f ~/.profile ]; then
    echo "Sourcing profile"
    source ~/.profile
fi

if [ -z ${CONTINUUM_HOME+x} ]; then
    echo "Setting CONTINUUM_HOME"
    export CONTINUUM_HOME=/opt/continuum/current
fi

# Setup up DB
if [ ! -f "/var/continuum/db_configured" ]; then
    echo "Setting up Continuum DB..."
    # Set correct server host
    echo "  mongodb_server: ${MONGODB_HOST}" >> /etc/continuum/continuum.yaml
    echo "  mongodb_password: ${MONGODB_PASSWORD}" >> /etc/continuum/continuum.yaml
    # Run DB initialization
    /opt/continuum/python/bin/python \
        /opt/continuum/current/common/install/init_mongodb.py -p "n813KLVh7sLowt08A66tEQ=="
    # Set flag for DB configured so as to not configure more that once.
    touch /var/continuum/db_configured
fi

# https://stackoverflow.com/questions/39082768/what-does-set-e-and-exec-do-for-docker-entrypoint-scripts?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
exec "$@"