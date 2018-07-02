FROM ubuntu:16.04
LABEL maintainer="a.guillermo.guzman@gmail.com"

RUN apt-get update && apt-get install -y \
    curl=7.47.0-1ubuntu2.8 \
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

ENV CONTINUUM_HOME=/opt/continuum/current
ENV PATH=$CONTINUUM_HOME/common/bin:$CONTINUUM_HOME/client/bin:$PATH

ENV ORACLE_HOME=$CONTINUUM_HOME/common/lib/instantclient_11_2\
ENV LD_LIBRARY_PATH=$ORACLE_HOME

WORKDIR $CONTINUUM_HOME

ADD ./entrypoint.sh $CONTINUUM_HOME
# UI and messagehub ports
EXPOSE 8080 8083

HEALTHCHECK --start-period=3s --interval=10s --timeout=1s --retries=3 \
    CMD curl --fail http://localhost:8080 || exit 1

ENTRYPOINT ["./entrypoint.sh"]
CMD ["$CONTINUUM_HOME/common/bin/ctm-start-services"]
