#!/usr/bin/env bash
set -e


if [[ -z "${CONTINUUM_HOME}" || -z "$(which ctm-start-services)" ]]; then
    echo "CONTINUUM_HOME not set or start script not found"
    exit 1
fi

CONFIG_FILE=/etc/continuum/continuum.yaml
if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "Configuration file not found or not writable"
    exit 1
fi

# This should not be here since it's only in the context of running in Ossum,
# but it provides a sanity check when starting the container to let the
# operator know the status of Ossum config.
if [[ -z ${OSSUM_JWT_ISSUER} \
    || -z ${OSSUM_JWT_AUDIENCE} \
    || -z ${OSSUM_OAUTH_URL} \
    || -z ${OSSUM_OAUTH_CLIENT_ID} \
    || -z ${OSSUM_OAUTH_SECRET} \
    || -z ${CONTINUUM_MONOGDB_NAME} \
    || -z ${CONTINUUM_MONOGDB_REPLICASET_HOSTS} \
    || -z ${CONTINUUM_MONOGDB_REPLICASET_NAME} \
    || -z ${CONTINUUM_MONOGDB_USERNAME} \
    || -z ${CONTINUUM_MONOGDB_PASSWORD} \
    || -z ${CONTINUUM_MONOGDB_AUTH} \
    || -z ${CONTINUUM_ENCRYPTION_KEY} \
    || -z ${APPLICATION_URL} \
    ]]; then
        echo "Ossum environment not complete"
fi

# ############################################################################
# Go through the environment and check to see with settings get applied in
# the config file as not every setting has environment variable support at
# runtime
# Find references to the available settings:
# https://community.versionone.com/VersionOne_Continuum/Administration/General_Settings/Configuration_Reference
# ############################################################################
add_setting() {
    local setting=$1
    local value=$2
    if [[ -n "${value}" ]]; then
        echo "  ${setting}: ${value}" >> ${CONFIG_FILE}
    fi
}

add_setting ui_debug ${UI_LOG_LEVEL}
add_setting rest_api_enable_basicauth ${BASIC_AUTH}
add_setting ui_enable_tokenauth ${TOKEN_AUTH}
add_setting msghub_enabled ${MSGHUB}
add_setting rest_api_allowed_origins ${APPLICATION_URL}
add_setting jobhandler_debug ${JOB_HANDLER_LOG_LEVEL}
add_setting ui_external_url ${UI_EXTERNAL_URL}

# ############################################################################
# Database initialization and update
# ############################################################################
echo "Preparing database configuration"

# Remove mongodb_database setting from config file if environment contains 
# database name to use. 
if [[ -n "${CONTNIUUM_MONGODB_NAME}" ]]; then
    sed -i "/mongodb_database/d" ${CONFIG_FILE}
fi

if [[ -n "${CONTINUUM_ENCRYPTION_KEY}" ]]; then
    # Encryption encryption key with default key
    encrypted_encryption_key=$(${CONTINUUM_HOME}/common/install/ctm-encrypt "${CONTINUUM_ENCRYPTION_KEY}" "")
    # Replace encryption key with key from environment.
    sed -i "s|^\s\skey:.*$|  key: ${encrypted_encryption_key}|" ${CONFIG_FILE}
fi

if [[ -n "${MONOLITH}" ]]; then
    if [[ -z "$(which mongod)" ]]; then
        echo "Attempting to run as monolith but could not find MongoDB"
        exit 1
    fi
    echo "Starting MongoDB"
    run_mongo="mongod --bind_ip localhost --port 27017 --dbpath /data/db"
    $(${run_mongo}) &
fi

# On upgrades init_mongodb.py will run again, running into a
# DuplicateKeyError, failing to change the admin db password out from
# under you, which is the behavior we want.
# We want to add something more robust than relying on the exception
echo "Initializing and running database upgrades"
${CONTINUUM_HOME}/common/install/init_mongodb.py || ${CONTINUUM_HOME}/common/updatedb.py || true

# File corruption always causing login issues.
shelf_file=/var/continuum/ui/cskuisession.shelf
if [[ -f ${shelf_file} ]]; then
    rm -f ${shelf_file}
fi

logs=/var/continuum/log
ui=${logs}/ctm-ui.log
core=${logs}/ctm-core.log
jobhandler=${logs}/ctm-jobhandler.log
msghub=${logs}/ctm-msghub.log
poller=${logs}/ctm-poller.log
echo "Starting Continuum services"
ctm-start-services && tail -F ${ui} ${core} ${jobhandler} ${msghub} ${poller}

exec "$@"
