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
    if [[ -n "${OSSUM_KEYSET_URL}" && -n "${OSSUM_JWK_ISS}" && -n "${OSSUM_JWK_VALID_AUD}" ]]; then
        echo "[INFO] Preparing Ossum values"
        space=" "; two_spaces="  "
        echo "${two_spaces}OSSUM_JWK_URL:${space}${OSSUM_KEYSET_URL}" >> ${CONFIG_FILE}
        echo "${two_spaces}OSSUM_JWK_ISS:${space}${OSSUM_JWK_ISS}" >> ${CONFIG_FILE}
        echo "${two_spaces}OSSUM_JWK_VALID_AUD:${space}${OSSUM_JWK_VALID_AUD}" >> ${CONFIG_FILE}
    fi
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
    # when running python script.
    #
    #
    using_original_script=$(grep "#!/opt/continuum/python/bin/python2.7 -OO" ${encrypt})

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

    #
    # Encrypt administrator password.
    #
    #
    if [ -n "${using_original_script}" ];then
        DEFAULT_ADMIN_PASSWORD=$(${encrypt} "password" "${CONTINUUM_ENCRYPTION_KEY}")
    else
        DEFAULT_ADMIN_PASSWORD=$(${encrypt} "password" --key "${CONTINUUM_ENCRYPTION_KEY}")
    fi

    run_mongo_command="mongod --bind_ip localhost --port 27017 --dbpath /data/db"
    [ -n "${RUN_AS_MONOLITH}" ] && (echo "[INFO] Starting MongoDB" && $(${run_mongo_command}) &)

    #
    # On upgrades init_mongodb.py will run again, running into a
    # DuplicateKeyError, failing to change the admin db password out from
    # under you, which is the behavior we want.
    # TODO: We want to add something more robust than relying on the exception
    #
    #
    echo "[INFO] Initializing and running database upgrades"
    ${CONTINUUM_HOME}/common/install/init_mongodb.py --password "${DEFAULT_ADMIN_PASSWORD}" &> /dev/null \
    || ${CONTINUUM_HOME}/common/updatedb.py &> /dev/null
fi

#
# File corruption always causing login issues.
#
#
shelf_file=/var/continuum/ui/cskuisession.shelf
[ -f ${shelf_file} ] && rm -f ${shelf_file}

exec "$@"
