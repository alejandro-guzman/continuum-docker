FROM ubuntu:16.04
LABEL maintainer.name="Alejandro Guzman" \
      maintainer.email="a.guillermo.guzman@gmail.com"

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
    && echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" \
    >> /etc/apt/sources.list.d/mongodb-org-3.2.list \
    && apt-get update \
    && apt-get install -y \
    curl \
    mongodb-org \
    # Enables Tasks to connect via SSH
    openssh-client \
    python=2.7.12-1~16.04 \
    sudo

ARG INSTALLER
LABEL continuum.installer=$INSTALLER
ENV CONTINUUM_INSTALLER=$INSTALLER

WORKDIR /tmp
RUN set -x \
    && curl --silent --output install.sh $CONTINUUM_INSTALLER \
    && chmod +x install.sh \
    # Installation wasn't successful until source line was removed
    && sed -i '/source ${WHICHPROFILE}/d' ./install.sh \
    # -s silent, -m skip data initialization, -p skip starting services
    && ./install.sh -m -p -s

ENV CONTINUUM_HOME="/opt/continuum/current"
ENV PATH="$CONTINUUM_HOME/common/bin:$CONTINUUM_HOME/client/bin:$PATH" \
    ORACLE_HOME="$CONTINUUM_HOME/common/lib/instantclient_11_2"
ENV LD_LIBRARY_PATH="$ORACLE_HOME" \
    SKIP_DATABASE="" \
    RUN_AS_MONOLITH="true" \
    CONTINUUM_ENCRYPTION_KEY="defaultkey" \
    CONTINUUM_MONGODB_SERVER="localhost" \
    CONTINUUM_MONGODB_PORT=27017 \
    CONTINUUM_MONGODB_NAME="continuum"
#    CONTINUUM_MONGODB_USERNAME="continuum" \
    # continuum encrypted with `defaultkey`
#    CONTINUUM_MONGODB_PASSWORD="WC52OB8O/MniQ/JRxBrTbw==" \
#    CONTINUUM_MONGODB_AUTH="admin"

ENV UI_PORT=6555 \
    UI_DEBUG_LOG=10


WORKDIR $CONTINUUM_HOME

RUN groupadd --gid 999 continuum \
    && useradd --uid 999 --gid continuum --groups root,sudo,mongodb --create-home continuum \
    && echo continuum:continuum | chpasswd \
    && mkdir --parent /data/db \
    && chown --recursive continuum:root \
    /opt/continuum \
    /etc/continuum \
    /var/continuum

COPY --chown=continuum:root ./entrypoint.sh $CONTINUUM_HOME
COPY --chown=continuum:root ./healthcheck.py $CONTINUUM_HOME
COPY --chown=continuum:root ./start-ctm.sh $CONTINUUM_HOME

# UI and messagehub ports
EXPOSE 8080 8083

VOLUME /var/continuum/logs /data/db

#USER continuum

HEALTHCHECK --start-period=3s --interval=3s --retries=3 \
    CMD ["python", "./healthcheck.py"]

ENTRYPOINT ["./entrypoint.sh"]
CMD ["/bin/bash", "-c", "./start-ctm.sh"]
