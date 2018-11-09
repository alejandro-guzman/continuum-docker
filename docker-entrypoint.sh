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

if [[ -z ${OSSUM_JWT_ISSUER} || -z ${OSSUM_JWT_AUDIENCE} \
    || -z ${OSSUM_OAUTH_URL} || -z ${OSSUM_OAUTH_CLIENT_ID} \
    || -z ${OSSUM_OAUTH_SECRET} ]]; then
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

# ############################################################################
# Database initialization and update
# ############################################################################
echo "Preparing database configuration"

# Remove mongodb_database setting from config file, environment
# variables passed in will handle Mongo settings
sed -i "/mongodb_database/d" ${CONFIG_FILE}

# If we did not pass an encryption key we exit.
if [[ -z "${CONTINUUM_ENCRYPTION_KEY}" ]]; then
    echo "$(basename $0) requires a CONTINUUM_ENCRYPTION_KEY"
    exit 1
fi

encrypt=${CONTINUUM_HOME}/common/install/ctm-encrypt

# Prevents failure when running against a different version
# of the encrypt script. The original script uses double optimization
# when running python script. Note: Not including "|| true" will result in
# the script exiting prematurely.
using_original_script=$(grep "#!/opt/continuum/python/bin/python2.7 -OO" ${encrypt} || true)

if [[ -n "${using_original_script}" ]];then
    # Original script relies on exactly 2 arguments
    ENCRYPTED_ENCRYPTION_KEY=$(${encrypt} "${CONTINUUM_ENCRYPTION_KEY}" "")
else
    # New script uses a named optional parameter for `key`
    ENCRYPTED_ENCRYPTION_KEY=$(${encrypt} "${CONTINUUM_ENCRYPTION_KEY}" --key "")
fi

# Replace encryption key with key from environment.
if [[ -f "${CONFIG_FILE}" ]] ; then
    sed -i "s|^\s\skey:.*$|  key: ${ENCRYPTED_ENCRYPTION_KEY}|" ${CONFIG_FILE}
fi

if [[ -n "${MONOLITH}" ]]; then
    echo "Starting MongoDB"
    run_mongo="mongod --bind_ip localhost --port 27017 --dbpath /data/db"
    $(${run_mongo}) &
fi

# On upgrades init_mongodb.py will run again, running into a
# DuplicateKeyError, failing to change the admin db password out from
# under you, which is the behavior we want.
# TODO: We want to add something more robust than relying on the exception
echo "Initializing and running database upgrades"

init_db=${CONTINUUM_HOME}/common/install/init_mongodb.py
using_original_initdb=$(grep ".*.add_argument.*\-\-password" ${init_db} || true)

if [[ -n "${using_original_initdb}" ]]; then

    # Encrypt administrator password.
    if [ -n "${using_original_script}" ];then
        DEFAULT_ADMIN_PASSWORD=$(${encrypt} "password" "${CONTINUUM_ENCRYPTION_KEY}")
    else
        DEFAULT_ADMIN_PASSWORD=$(${encrypt} "password" --key "${CONTINUUM_ENCRYPTION_KEY}")
    fi

    ${init_db} --password "${DEFAULT_ADMIN_PASSWORD}" \
    || ${CONTINUUM_HOME}/common/updatedb.py \
    || true

else
    ${init_db} \
    || ${CONTINUUM_HOME}/common/updatedb.py \
    || true
fi

# File corruption always causing login issues.
shelf_file=/var/continuum/ui/cskuisession.shelf
if [[ -f ${shelf_file} ]]; then
    rm -f ${shelf_file}
fi

echo "Starting Continuum services"
ctm-start-services && tail -f /var/continuum/log/ctm-ui.log

exec "$@"
