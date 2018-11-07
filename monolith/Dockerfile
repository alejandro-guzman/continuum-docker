FROM cycletime/continuum:latest

LABEL maintainer.name="Alejandro Guzman"
LABEL maintainer.username="@agguzman"
LABEL maintainer.email="aguzman@collab.net"

USER root

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
    && echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" \
        >> /etc/apt/sources.list.d/mongodb-org-3.2.list \
    && apt-get update \
    && apt-get install -y \
    mongodb-org

ENV RUN_AS_MONOLITH true
ENV CONTINUUM_ENCRYPTION_KEY defaultkey
ENV CONTINUUM_MONGODB_SERVER localhost
ENV CONTINUUM_MONGODB_PORT 27017
ENV CONTINUUM_MONGODB_NAME continuum
#    CONTINUUM_MONGODB_USERNAME="continuum" \
    # continuum encrypted with `defaultkey`
#    CONTINUUM_MONGODB_PASSWORD="WC52OB8O/MniQ/JRxBrTbw==" \
#    CONTINUUM_MONGODB_AUTH="admin"

VOLUME /var/continuum/logs /data/db
