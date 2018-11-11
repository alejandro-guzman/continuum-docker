# ############################################################################
# Frontend dev web app include webpack dev driver with hot module reload
# ############################################################################
FROM node:6.14.3-jessie as frontend

LABEL maintainer.name="Alejandro Guzman"
LABEL maintainer.username="@agguzman"
LABEL maintainer.email="aguzman@collab.net"

ENV APP /app
WORKDIR $APP

EXPOSE 3000

COPY ./dev/start_frontend.sh /
ENTRYPOINT ["/start_frontend.sh"]

# ############################################################################
# Backend application includes all of continuum services
# The configuaration is dictated by the installer version that gets pulled.

# If there are changes to supporting files that development depends on you
# would need to update the version.

# Currently all python dependencies live in this directory and are not coming
# from thirdparty or the project directory - it's possible they will get out
# of sync at some point.
# ############################################################################
FROM ubuntu:16.04 as backend

LABEL maintainer.name="Alejandro Guzman"
LABEL maintainer.username="@agguzman"
LABEL maintainer.email="aguzman@collab.net"
LABEL is-production="false"

ARG DEBIAN_FRONTEND=noninteractive

ARG INSTALLER_LINK

# Release of Continuum to pull
ENV CONTINUUM_VERSION 18.3.0.67

# Location of Continuum releases
ENV CONTINUUM_RELEASES https://s3.amazonaws.com/versionone-downloads/continuum

COPY ./dev/requirements.txt /

RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    python \
    python-pip \
    openssh-client \
    openssl \
    ca-certificates \
    man \
    vim \
    # Dev dependencies that support Python packages in development. These are
    # specific to Ubuntu 16.04 and are named different on other platforms
    libffi-dev \
    libkrb5-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    # For now having the reqs here is okay since they do not change often
    # but eventually we'd want to leverage mounting the local thirdparty repo
    # if it's available or downloading the raw reqs from thirdparty repo.
    && pip install --upgrade pip==9.0.0 \
    && pip install --no-cache-dir -r /requirements.txt \
    && set -ex \
    && if [ -n "${INSTALLER_LINK}" ]; then \
            export LINK=${INSTALLER_LINK}; \
        else \
            export LINK=${CONTINUUM_RELEASES}/continuum-${CONTINUUM_VERSION}-installer.sh; \
        fi \
    && cd /tmp \
    && curl -o install ${LINK} \
    && chmod +x ./install \
    # Installation wasn't successful until source line was removed
    && sed -i '/source ${WHICHPROFILE}/d' ./install \
    # -m skip data initialization, -p skip starting services, -s silent
    && ./install -m -p -s \
    && rm -f /tmp/install \
    && rm -rf /opt/continuum/current/* \
    # Create continuum service user
    && groupadd --system continuum \
    && useradd --gid continuum --groups sudo --system continuum \
    && echo continuum:continuum | chpasswd \
    # Change permissions
    && chown -R continuum:continuum /opt/continuum /etc/continuum /var/continuum

# ############################################################################
# This is an attempt to manually add the support files and directory structure.
# It may be more trouble than it's work to have to jump through the hoops of
# coordinating the encryption key with the installer and configuration file.
# ############################################################################
#RUN set -ex \
#    && mkdir -p /opt/continuum \
#        /etc/continuum \
#        /var/continuum \
#    && echo "\n\
#service ctm-ui\n\
#service ctm-msghub\n\
#service ctm-jobhandler\n\
#service ctm-core\n\
#service ctm-poller\n\
#" >> /etc/continuum/service.conf \
#    && echo "\n\
#---\n\
#system:\n\
#    key: H6YfeTSBhyF71ZTU7hldFw==\n\
#    uicache: /var/continuum/ui\n\
#    tmpdir: /var/continuum/tmp\n\
#    logfiles: /var/continuum/log\n\
#" >> /etc/continuum/continuum.yaml

ENV CONTINUUM_HOME /opt/continuum/current
ENV PATH $CONTINUUM_HOME/common/bin:$CONTINUUM_HOME/client/bin:/opt/continuum/python/bin:$PATH
ENV ORACLE_HOME $CONTINUUM_HOME/common/lib/instantclient_11_2
ENV LD_LIBRARY_PATH $ORACLE_HOME

# ############################################################################
# Ossum related environment varaibles are convenient to have for testing JWT
# authentication against an existing user in the Ossum auth server and Ossum
# plugin config and pipeline steps.
# ############################################################################
ENV OSSUM_OAUTH_URL https://api.test.ossum.cloud/oauth
ENV OSSUM_JWT_ISSUER urn:cycletime:iss:idp
ENV OSSUM_JWT_AUDIENCE devops
ENV OSSUM_OAUTH_CLIENT_ID 690ecc931c3c42e517aef9e40dd636668e6da93c158058da04dc8001650563e0
ENV OSSUM_OAUTH_SECRET 5b727421517d35bcc6147179e5d7e9429ef52147aa5966b29fa2bd7381703e17

ENV UI_LOG_LEVEL 10
ENV JOB_HANDLER_LOG_LEVEL 10

WORKDIR $CONTINUUM_HOME

# 8080 and 8083 (message hub) are what is used to interact with Continuum
EXPOSE 8080 8083

COPY ./scripts/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
