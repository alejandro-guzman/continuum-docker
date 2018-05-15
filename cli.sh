#!/usr/bin/env bash


function build {
    docker image build \
        --tag continuum-prod \
        --build-arg INSTALLER=$1 \
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
