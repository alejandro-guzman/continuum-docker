FROM ubuntu:16.04
LABEL maintainer ="a.guillermo.guzman@gmail.com"


RUN apt-get update && apt-get install -y \
    build-essential \
    cron \
    curl \
    libffi-dev \
    libkrb5-dev \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    python \
    sudo

ARG INSTALLER=""
ENV MY_CTM_INSTALLER=$INSTALLER

RUN set -xe && \
    cd /tmp && \
    # Download installer
    curl -o install.sh $INSTALLER && \
    chmod +x install.sh && \
    # Installation wasn't successful until source line was removed
    sed -i '/source ${WHICHPROFILE}/d' install.sh && \
    # -s silent, -m skip data initialization, -p skip starting services
    ./install.sh -m -p -s

ENV APP=/opt/continuum/current
WORKDIR $APP

ADD ./entrypoint.sh $APP

# ui and messagehub
EXPOSE 8080 8083

ENTRYPOINT ["/opt/continuum/current/entrypoint.sh"]
CMD ["ctm-start-services"]
