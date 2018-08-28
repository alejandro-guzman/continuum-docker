#!/usr/bin/env bash
set -e


#
# If CONTINUUM_HOME or command location cannot be determined,
# exit immediately, something is wrong with the image.
#
#
[ -z "${CONTINUUM_HOME}" ] && (echo "[ERROR] CONTINUUM_HOME variable not set" && exit 1)
[ -z "$(which ctm-start-services)" ] && (echo "[ERROR] Cannot find Continuum commands" && exit 1)

#
# Standard configuration file with every Continuum install.
# Contains entries we'd want to modify/remove or add to in different cases depending on the version of installer.
#
#
CONFIG_FILE="/etc/continuum/continuum.yaml"

#
# Include Ossum related keys/values in configuration for authentication.
# TODO: Ossum jwk environment variables are stored in config file, do we
# really need them there if ossum is only going to use them? maybe just
# retrieve vars from environment in jwt_auth module instead of placing them
# in the config file... Also let's name the vars more generic.
#
if [ -f "${CONFIG_FILE}" ]; then
    space=" "; two_spaces="  "

    if [[ -n "${OSSUM_KEYSET_URL}" && -n "${OSSUM_JWK_ISS}" && -n "${OSSUM_JWK_VALID_AUD}" ]]; then
        echo "[INFO] Preparing Ossum values"
        echo "${two_spaces}OSSUM_JWK_URL:${space}${OSSUM_KEYSET_URL}" >> ${CONFIG_FILE}
        echo "${two_spaces}OSSUM_JWK_ISS:${space}${OSSUM_JWK_ISS}" >> ${CONFIG_FILE}
        echo "${two_spaces}OSSUM_JWK_VALID_AUD:${space}${OSSUM_JWK_VALID_AUD}" >> ${CONFIG_FILE}
    fi

    #
    # TODO: Add a flag to enable all or part of these configurations.
    # We want most of these for Ossum but for other deployments we want them configurable.
    #
    #
    echo "${two_spaces}ui_debug:${space}${UI_LOG_LEVEL}" >> ${CONFIG_FILE}
    echo "${two_spaces}rest_api_enable_basicauth:${space}disabled" >> ${CONFIG_FILE}
    echo "${two_spaces}ui_enable_tokenauth:${space}disabled" >> ${CONFIG_FILE}
    echo "${two_spaces}msghub_enabled:${space}disabled" >> ${CONFIG_FILE}
    [ -z "${APPLICATION_URL}" ] && APPLICATION_URL="*"
    echo "${two_spaces}rest_api_allowed_origins:${space}\"${APPLICATION_URL}\"" >> ${CONFIG_FILE}
fi

#
# Attempt to setup database
#
#
if [ -z "${SKIP_DATABASE}" ]; then
    echo "[INFO] Preparing database configuration"

    #
    # Remove mongodb_database setting from config file, environment
    # variables passed in will handle Mongo settings
    #
    #
    sed -i "/mongodb_database/d" ${CONFIG_FILE}

    #
    # If we did not pass an encryption key we exit.
    #
    #
    [ -z "${CONTINUUM_ENCRYPTION_KEY}" ] && (echo "[ERROR] $(basename $0) requires a CONTINUUM_ENCRYPTION_KEY" && exit 1)

    encrypt=${CONTINUUM_HOME}/common/install/ctm-encrypt

    #
    # Prevents failure when running against a different version
    # of the encrypt script. The original script uses double optimization
    # when running python script. Note: Not including "|| true" will result in
    # the script exiting prematurely.
    #
    #
    using_original_script=$(grep "#!/opt/continuum/python/bin/python2.7 -OO" ${encrypt} || true)

    if [ -n "${using_original_script}" ];then
        # Original script relies on exactly 2 arguments
        ENCRYPTED_ENCRYPTION_KEY=$(${encrypt} "${CONTINUUM_ENCRYPTION_KEY}" "")
    else
        # New script uses a named optional parameter for `key`
        ENCRYPTED_ENCRYPTION_KEY=$(${encrypt} "${CONTINUUM_ENCRYPTION_KEY}" --key "")
    fi

    #
    # Replace encryption key with key from environment.
    #
    #
    [ -f "${CONFIG_FILE}" ] && sed -i "s|^\s\skey:.*$|  key: ${ENCRYPTED_ENCRYPTION_KEY}|" ${CONFIG_FILE}

    run_mongo_command="mongod --bind_ip localhost --port 27017 --dbpath /data/db"
    [ -n "${RUN_AS_MONOLITH}" ] && (echo "[INFO] Starting MongoDB" && $(${run_mongo_command}) &)

    #
    # On upgrades init_mongodb.py will run again, running into a
    # DuplicateKeyError, failing to change the admin db password out from
    # under you, which is the behavior we want.
    # TODO: We want to add something more robust than relying on the exception
    #
    #
    init_db=${CONTINUUM_HOME}/common/install/init_mongodb.py
    using_original_initdb=$(grep ".*.add_argument.*\-\-password" ${init_db} || true)
    echo "[INFO] Initializing and running database upgrades"
    if [ -n "${using_original_initdb}" ]; then

        #
        # Encrypt administrator password.
        #
        #
        if [ -n "${using_original_script}" ];then
            DEFAULT_ADMIN_PASSWORD=$(${encrypt} "password" "${CONTINUUM_ENCRYPTION_KEY}")
        else
            DEFAULT_ADMIN_PASSWORD=$(${encrypt} "password" --key "${CONTINUUM_ENCRYPTION_KEY}")
        fi

        ${init_db} --password "${DEFAULT_ADMIN_PASSWORD}" &> /dev/null \
        || ${CONTINUUM_HOME}/common/updatedb.py &> /dev/null \
        || true

    else
        ${init_db} &> /dev/null \
        || ${CONTINUUM_HOME}/common/updatedb.py &> /dev/null \
        || true
    fi
fi

#
# File corruption always causing login issues.
#
#
shelf_file=/var/continuum/ui/cskuisession.shelf
[ -f ${shelf_file} ] && rm -f ${shelf_file}

exec "$@"
