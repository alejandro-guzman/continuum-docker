FROM ubuntu:16.04
LABEL maintainer="a.guillermo.guzman@gmail.com"

RUN apt-get update && apt-get install -y \
    # Used for installer, soon to be removed in favor of building file deps 
    # by hand.
    curl=7.47.0-1ubuntu2.8 \
    # Supporting libs for python deps.
    libffi-dev=3.2.1-4 \
    libkrb5-dev=1.13.2+dfsg-5ubuntu2 \
    libldap2-dev=2.4.42+dfsg-2ubuntu3.3 \
    libsasl2-dev=2.1.26.dfsg1-14build1 \
    libssl-dev=1.0.2g-1ubuntu4.13 \
    # Enables Tasks to connect via SSH.
    openssh-client=1:7.2p2-4ubuntu2.4 \
    # Python 2.7 and PIP dependency manager.
    python=2.7.12-1~16.04 \
    python-pip=8.1.1-2ubuntu0.4 \
    # TODO: Check this..
    sudo=1.8.16-0ubuntu1.5 \
    # For debugging within the container.
    man \
    nano \
    vim

COPY ./dev/requirements.txt /
RUN pip install --upgrade pip==9.0.0 && \
    pip install --no-cache-dir -r /requirements.txt

# TODO: remove installer and add supporting files by hand.
ARG INSTALLER

WORKDIR /tmp
RUN set -x ; \
    curl --silent --output ./install.sh $INSTALLER ; \
    chmod +x ./install.sh ; \
    # Installation wasn't successful until source line was removed
    sed -i '/source ${WHICHPROFILE}/d' ./install.sh ; \
    # -s silent, -m skip data initialization, -p skip starting services
    ./install.sh -m -p -s && \
    # Clean up
    rm -f /tmp/install.sh

ENV CONTINUUM_HOME=/opt/continuum/current
ENV PATH=$CONTINUUM_HOME/common/bin:$CONTINUUM_HOME/client/bin:$PATH
ENV PATH=/opt/continuum/python/bin:$PATH
ENV ORACLE_HOME=$CONTINUUM_HOME/common/lib/instantclient_11_2
ENV LD_LIBRARY_PATH=$ORACLE_HOME

WORKDIR $CONTINUUM_HOME

RUN rm -rf $CONTINUUM_HOME/*

COPY ./entrypoint.sh /
COPY ./dev/start.sh /

# UI and messagehub ports
EXPOSE 8080 8083

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash", "-c", "/start.sh"]
