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
if [ -z ${SKIP_DB+x} ]; then
    echo "Setting Continuum DB"
    # Remove mongodb_database setting from config file, environment variables passed in will handle mongo settings
    sed -i '/mongodb_database/d' /etc/continuum/continuum.yaml

    DEFAULT_ADMIN_PASSWORD="n813KLVh7sLowt08A66tEQ=="  # "password"
    ${CONTINUUM_HOME}/common/updatedb.py || \
        ${CONTINUUM_HOME}/common/install/init_mongodb.py --password $DEFAULT_ADMIN_PASSWORD
fi

# https://stackoverflow.com/questions/39082768/what-does-set-e-and-exec-do-for-docker-entrypoint-scripts?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
exec "$@"