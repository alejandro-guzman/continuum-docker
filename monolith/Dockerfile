FROM continuum:prod

LABEL is-production="false"

USER root

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
    && echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" \
        >> /etc/apt/sources.list.d/mongodb-org-3.2.list \
    && apt-get update && apt-get install -y \
    mongodb-org

ENV MONOLITH true
#ENV CONTINUUM_ENCRYPTION_KEY defaultkey
#ENV CONTINUUM_MONGODB_SERVER localhost
#ENV CONTINUUM_MONGODB_PORT 27017
#ENV CONTINUUM_MONGODB_NAME continuum

# TODO: continuum user not found even though it was created in the parent image
# USER continuum

VOLUME /var/continuum/logs /data/db
