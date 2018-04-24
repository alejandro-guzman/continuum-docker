#!/usr/bin/env bash


function build_ubuntu14 {

    docker image build \
        --tag ctm-ubuntu-14 \
        --file Dockerfile-continuum-production-ubuntu-mongo-1404 \
        .

    docker container run \
        --rm \
        --name ctm-ubuntu-14-container \
        --publish 127.0.0.1:9090:8080 \
        ctm-ubuntu-14
}

function compose_14 {
    docker-compose up --build
}


