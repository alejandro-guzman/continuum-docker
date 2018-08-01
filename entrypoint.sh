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

CONFIG=/etc/continuum/continuum.yaml

# URL to JWK public key, Issuer, and Audience for Ossum app
# Set default values so inserting them into CONFIG does not
# cause parsing errors when read. Default values allows us
# to run this container outside the context of Ossum.
[ -z ${OSSUM_KEYSET_URL} ] && OSSUM_KEYSET_URL="0"
[ -z ${OSSUM_JWK_ISS} ] && OSSUM_JWK_ISS="0"
[ -z ${OSSUM_JWK_VALID_AUD} ] && OSSUM_JWK_VALID_AUD="0"

if [ -f ${CONFIG} ]; then
    echo "  OSSUM_JWK_URL: ${OSSUM_KEYSET_URL}" >> ${CONFIG}
    echo "  OSSUM_JWK_ISS: ${OSSUM_KEYSET_URL}" >> ${CONFIG}
    echo "  OSSUM_JWK_VALID_AUD: ${OSSUM_KEYSET_URL}" >> ${CONFIG}
fi

# Setup up DB
if [ -z ${SKIP_DATABASE} ]; then
    echo "Initializing and running upgrades on Continuum database.."

    config=/etc/continuum/continuum.yaml

    # Remove mongodb_database setting from config file, environment
    # variables passed in will handle Mongo settings
    sed -i "/mongodb_database/d" ${CONFIG}

    if [ -z ${CONTINUUM_ENCRYPTION_KEY} ]; then
        echo "$(basename $0) requires a CONTINUUM_ENCRYPTION_KEY, exiting.."
        exit 1
    fi

    encrypt=${CONTINUUM_HOME}/common/install/ctm-encrypt

    # Prevents failure when running against a different version
    # of the encrypt script
    original_script=$(grep "#!/opt/continuum/python/bin/python2.7 -OO" ${encrypt})

    if [ -z ${original_script} ];then
        # Use older script if grep didn't match
        # New script uses 1 level of optimization
        ENCRYPTED_KEY=$(${encrypt} ${CONTINUUM_ENCRYPTION_KEY} --key "")
    else
        ENCRYPTED_KEY=$(${encrypt} ${CONTINUUM_ENCRYPTION_KEY} "")
    fi
    # Replace encryption key with key from environment.
    sed -i "s/^\s\skey:.*$/  key: ${ENCRYPTED_KEY}/" ${CONFIG}

    # On upgrades init_mongodb.py will run again, running into a
    # DuplicateKeyError, failing to change the admin db password out from
    # under you, which is the behavior we want.
     if [ -z ${original_script} ];then
        DEFAULT_ADMIN_PASSWORD=$(${encrypt} "password" --key ${CONTINUUM_ENCRYPTION_KEY})
    else
        DEFAULT_ADMIN_PASSWORD=$(${encrypt} "password" ${CONTINUUM_ENCRYPTION_KEY})
    fi

    ${CONTINUUM_HOME}/common/install/init_mongodb.py --password ${DEFAULT_ADMIN_PASSWORD} || ${CONTINUUM_HOME}/common/updatedb.py
fi

# File corruption always causing login issues.
shelf_file=/var/continuum/ui/cskuisession.shelf
if [ -f ${shelf_file} ]; then
    rm -f ${shelf_file}
fi

# https://stackoverflow.com/questions/39082768/what-does-set-e-and-exec-do-for-docker-entrypoint-scripts?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa
exec "$@"
