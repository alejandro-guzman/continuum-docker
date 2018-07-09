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
    echo "Initializing and running upgrades on Continuum database.."

    config=/etc/continuum/continuum.yaml

    # Remove mongodb_database setting from config file, environment
    # variables passed in will handle Mongo settings
    sed -i "/mongodb_database/d" $config

    KEY=$(${CONTINUUM_HOME}/common/install/ctm-encrypt \
        ${CONTINUUM_ENCRYPTION_KEY} "")

    # Replace encryption key with key from environment.
    sed -i "s/^\s\skey:.*$/  key: ${KEY}/" $config

    # On upgrades init_mongodb.py will run again, running into a
    # Duplicate Key Error, failing to change the admin db password out from
    # under you, which is the behavior we want.
    DEFAULT_ADMIN_PASSWORD=$(${CONTINUUM_HOME}/common/install/ctm-encrypt \
        "password" ${CONTINUUM_ENCRYPTION_KEY})

    ${CONTINUUM_HOME}/common/install/init_mongodb.py \
        --password $DEFAULT_ADMIN_PASSWORD || \
    ${CONTINUUM_HOME}/common/updatedb.py
fi

# File corruption always causing login issues.
shelf_file=/var/continuum/ui/cskuisession.shelf
if [ -f $shelf_file ]; then
    rm -f $shelf_file
fi

# https://stackoverflow.com/questions/39082768/what-does-set-e-and-exec-do-for-docker-entrypoint-scripts?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
exec "$@"