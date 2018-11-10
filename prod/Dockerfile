FROM ubuntu:16.04

LABEL maintainer.name="Alejandro Guzman"
LABEL maintainer.username="@agguzman"
LABEL maintainer.email="aguzman@collab.net"
LABEL is-production="true"

ARG DEBIAN_FRONTEND=noninteractive

# A link to the installer can be passed in. This allows private installer for
# debugging or to deviate from the regular release cadence. If a link is not
# passed in when building this image, it will default to an official installer
# specified by CONTINUUM_VERSION
ARG INSTALLER_LINK
ENV INSTALLER_LINK ${INSTALLER_LINK}

# Release of Continuum to pull
ENV CONTINUUM_VERSION 18.3.0.67

# Location of Continuum releases
ENV CONTINUUM_RELEASES https://s3.amazonaws.com/versionone-downloads/continuum

## Install python runtime and utils for installation and runtime
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    python \
    openssh-client \
    openssl \
    ca-certificates \
    # Install Continuum
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
    # Create continuum service user
    && groupadd --system continuum \
    && useradd --gid continuum --groups sudo --system continuum \
    && echo continuum:continuum | chpasswd \
    # Change permissions
    && chown -R continuum:continuum /opt/continuum /etc/continuum /var/continuum

ENV CONTINUUM_HOME /opt/continuum/current
ENV PATH=${CONTINUUM_HOME}/common/bin:${CONTINUUM_HOME}/client/bin:${PATH}
ENV ORACLE_HOME=${CONTINUUM_HOME}/common/lib/instantclient_11_2
ENV LD_LIBRARY_PATH=${ORACLE_HOME}

# Expose logs directory, includes all services and automation
VOLUME /var/continuum/log

# 8080 and 8083 (message hub) are what is used to interact with Continuum
EXPOSE 8080 8083

# Continuum runs under the continuum user
USER continuum

# Move into CONTINUUM_HOME
WORKDIR $CONTINUUM_HOME

# Service health check that ping the Continuum at intervals
COPY ./scripts/healthcheck.py .
HEALTHCHECK --start-period=3s --interval=3s --retries=3 \
    CMD ["python", "./healthcheck.py"]

COPY ./scripts/docker-entrypoint.sh .
ENTRYPOINT ["./docker-entrypoint.sh"]
