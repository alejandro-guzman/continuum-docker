#!/usr/bin/env bash

set -e

installer=$1
source ./cli.sh ${installer}; build

repo=$2  # ex: "foo.dkr.ecr.us-east-1.amazonaws.com/continuum"
tag=$3
docker image tag continuum-prod:latest ${repo}:${tag}

docker push ${repo}
