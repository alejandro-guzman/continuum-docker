#!/usr/bin/env bash

set -e

INSTALLER_LINK=$1

docker image build \
    --tag continuum-prod \
    --build-arg INSTALLER=${INSTALLER_LINK} \
    --file Dockerfile \
    .
REPO=$2  # ex: "foo.dkr.ecr.us-east-1.amazonaws.com/continuum"
TAG=$3  # defaults to latest

docker image tag continuum-prod:latest ${REPO}:${TAG}
docker push ${REPO}
