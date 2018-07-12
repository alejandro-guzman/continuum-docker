#!/usr/bin/env bash

build() {

    if [ -z "$1" ]; then
        link="https://s3.amazonaws.com/versionone-builds/continuum/installer/continuum-18.1.4.224-development-installer.sh"
    else
        link="$1"
    fi

    docker image build \
        --tag monolith-ctm \
        --build-arg INSTALLER=$link \
        --file monolith/Dockerfile \
        .
}

run() {
    docker container run \
        --rm \
        --name ctm \
        --publish "8080:8080" \
        --publish "8083:8083" \
        monolith-ctm
}
