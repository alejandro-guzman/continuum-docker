#!/usr/bin/env bash

installer_link=$1

function build {
    docker image build \
        --tag continuum-prod \
        --build-arg INSTALLER=${installer_link} \
        --file Dockerfile-continuum \
        .
}

function run {
    docker container run \
        --rm \
        --name continuum-prod-run \
        --publish 127.0.0.1:5000:8080 \
        continuum-prod
}

function compose {
    docker-compose up --build
}
