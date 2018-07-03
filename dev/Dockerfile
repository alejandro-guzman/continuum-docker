FROM ubuntu:16.04
LABEL maintainer="a.guillermo.guzman@gmail.com"

RUN apt-get update && apt-get install -y \
    curl=7.47.0-1ubuntu2.8 \
    # Enables Tasks to connect via SSH
    openssh-client=1:7.2p2-4ubuntu2.4 \
    python=2.7.12-1~16.04 \
    sudo=1.8.16-0ubuntu1.5 \
    # TODO: attach versions of these & sort
    libffi-dev \
    libkrb5-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    python-pip \
    vim \
    nano \
    man

COPY ./dev/requirements.txt /
RUN pip install --upgrade pip==9.0.0 && \
    pip install --no-cache-dir -r /requirements.txt

ARG INSTALLER

WORKDIR /tmp
RUN set -x ; \
    curl --silent --output ./install.sh $INSTALLER ; \
    chmod +x ./install.sh ; \
    # Installation wasn't successful until source line was removed
    sed -i '/source ${WHICHPROFILE}/d' ./install.sh ; \
    # -s silent, -m skip data initialization, -p skip starting services
    ./install.sh -m -p -s && \
    rm -f /tmp/install.sh

ENV CONTINUUM_HOME=/opt/continuum/current
ENV PATH=$CONTINUUM_HOME/common/bin:$CONTINUUM_HOME/client/bin:$PATH \
    PATH=/opt/continuum/python/bin:$PATH
ENV ORACLE_HOME=$CONTINUUM_HOME/common/lib/instantclient_11_2
ENV LD_LIBRARY_PATH=$ORACLE_HOME

WORKDIR $CONTINUUM_HOME

RUN rm -rf $CONTINUUM_HOME/*

COPY ./dev/entrypoint.sh /
COPY ./dev/start.sh /

# UI and messagehub ports
EXPOSE 8080 8083

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "-c", "/start.sh"]
