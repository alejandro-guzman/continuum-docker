FROM ubuntu:16.04
LABEL maintainer.name="Alejandro Guzman"
LABEL maintainer.email="a.guillermo.guzman@gmail.com"

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
    echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
    apt-get update && apt-get install -y \
    curl=7.47.0-1ubuntu2.8 \
    mongodb-org \
    # Enables Tasks to connect via SSH
    openssh-client=1:7.2p2-4ubuntu2.4 \
    python=2.7.12-1~16.04 \
    sudo=1.8.16-0ubuntu1.5

ARG INSTALLER
LABEL installer="$INSTALLER"

WORKDIR /tmp
RUN set -x ; \
    curl --silent --output ./install.sh $INSTALLER ; \
    chmod +x ./install.sh ; \
    # Installation wasn't successful until source line was removed
    sed -i '/source ${WHICHPROFILE}/d' ./install.sh ; \
    # -s silent, -m skip data initialization, -p skip starting services
    ./install.sh -m -p -s

ENV CONTINUUM_HOME="/opt/continuum/current"
ENV PATH="$CONTINUUM_HOME/common/bin:$CONTINUUM_HOME/client/bin:$PATH" \
    ORACLE_HOME="$CONTINUUM_HOME/common/lib/instantclient_11_2"
ENV LD_LIBRARY_PATH="$ORACLE_HOME" \
    SKIP_DATABASE="" \
#    CONTINUUM_MONGODB_SERVER="localhost" \
#    CONTINUUM_MONGODB_PORT=27017 \
    CONTINUUM_MONGODB_NAME="continuum"
#    CONTINUUM_MONGODB_USERNAME="continuum" \
    # continuum
#    CONTINUUM_MONGODB_PASSWORD="jQnkhqV13qC4W3iqiVMu8A==" \
#    CONTINUUM_MONGODB_AUTH="admin"

WORKDIR $CONTINUUM_HOME

RUN groupadd --gid 999 ctmuser && \
    useradd --uid 999 --gid ctmuser --groups root --create-home ctmuser && \
    mkdir --parent /data/db && \
    chown --recursive ctmuser:root \
    /opt/continuum \
    /etc/continuum \
    /var/continuum \
    /data/db

COPY --chown=ctmuser:root ./monolith/entrypoint.sh $CONTINUUM_HOME
COPY --chown=ctmuser:root ./healthcheck.py $CONTINUUM_HOME
COPY --chown=ctmuser:root ./run.sh $CONTINUUM_HOME

# UI and messagehub ports
EXPOSE 8080 8083

USER ctmuser

HEALTHCHECK --start-period=3s --interval=3s --retries=3  \
    CMD ["python", "./healthcheck.py"]

ENTRYPOINT ["./entrypoint.sh"]
CMD ["/bin/bash", "-c", "./run.sh"]

# Build image
# docker image build --tag monolith-ctm --build-arg INSTALLER=$INSTALLER --file monolith/Dockerfile .

# Run container
# docker container run --rm --publish "8080:8080" --publish "8083:8083" monolith-ctm
