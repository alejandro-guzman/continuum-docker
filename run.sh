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

# Start Continuum services
ctm-restart-services
# Keep container from exiting
while true; do sleep 10s; done