#!/usr/bin/env bash
set -e


if [ -z ${CONTINUUM_HOME} ]; then
    echo "CONTINUUM_HOME variable not set, exiting.."
    exit 1
fi

if [ -z $(which ctm-start-services) ]; then
    echo "Cannot find ctm-start-service command, exiting.."
    exit 1
fi

# Setup up DB
if [ -z ${SKIP_DATABASE} ]; then
    echo "Setting Continuum DB"
    # Remove mongodb_database setting from config file, environment variables passed in will handle mongo settings
    sed -i '/mongodb_database/d' /etc/continuum/continuum.yaml

    DEFAULT_ADMIN_PASSWORD="n813KLVh7sLowt08A66tEQ=="  # "password"
    ${CONTINUUM_HOME}/common/install/init_mongodb.py --password $DEFAULT_ADMIN_PASSWORD || ${CONTINUUM_HOME}/common/updatedb.py
    echo "Done setting Continuum DB"
fi

# File corruption always causing login issues.
shelf_file=/var/continuum/ui/cskuisession.shelf
if [ -f $shelf_file ]; then
    rm -f $shelf_file
fi

# https://stackoverflow.com/questions/39082768/what-does-set-e-and-exec-do-for-docker-entrypoint-scripts?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
exec "$@"