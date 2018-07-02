FROM ubuntu:16.04
LABEL maintainer.name="Alejandro Guzman"
LABEL maintainer.email="a.guillermo.guzman@gmail.com"

RUN apt-get update && apt-get install -y \
    curl=7.47.0-1ubuntu2.8 \
    # Enables Tasks to connect via SSH
    openssh-client=1:7.2p2-4ubuntu2.4 \
    python=2.7.12-1~16.04 \
    sudo=1.8.16-0ubuntu1.5

ARG INSTALLER
LABEL installer="$INSTALLER"

ARG CONTINUUM_ENCRYPTION_KEY
ENV CONTINUUM_ENCRYPTION_KEY="$CONTINUUM_ENCRYPTION_KEY"

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
    SKIP_DATABASE=""

WORKDIR $CONTINUUM_HOME

RUN groupadd --gid 999 ctmuser && \
    useradd --uid 999 --gid ctmuser --groups root --create-home ctmuser && \
    chown --recursive ctmuser:root \
    /opt/continuum \
    /etc/continuum \
    /var/continuum

COPY --chown=ctmuser:root ./entrypoint.sh $CONTINUUM_HOME
COPY --chown=ctmuser:root ./healthcheck.py $CONTINUUM_HOME
COPY --chown=ctmuser:root ./run.sh $CONTINUUM_HOME

# UI and messagehub ports
EXPOSE 8080 8083

USER ctmuser

HEALTHCHECK --start-period=3s --interval=3s --retries=3  \
    CMD ["python", "./healthcheck.py"]

ENTRYPOINT ["./entrypoint.sh"]
CMD ["/bin/bash", "-c", "./run.sh"]
