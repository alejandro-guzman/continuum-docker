#!/usr/bin/env bash

set -e
echo "Starting Continuum..."

sleep 5s
# Make sure ENV is set correctly
source ~/.profile
export CONTINUUM_HOME=/opt/continuum/current
#while true; do sleep 10s; done

# Setup up DB
if [ ! -f "/var/continuum/db_configured" ]; then
    echo "Setting up Continuum DB..."
    /opt/continuum/python/bin/python \
        /opt/continuum/current/common/install/init_mongodb.py -p "n813KLVh7sLowt08A66tEQ=="
    touch /var/continuum/db_configured
fi

# Start CTM
ctm-restart-services
# Keeps container from exiting
while true; do sleep 10s; done