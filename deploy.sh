#!/usr/bin/env bash
set -ex

base="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
username="continuumserviceuser"
organization="cycletime"
image="continuum"

echo "Logging into Docker using username ${username}"
cat ${HOME}/.docker/continuumserviceuser-pw | docker login -u ${username} --password-stdin || true

echo "Getting version from ${base}/docker-compose.yml"

version=$( grep -oP '(\d{2}\.\d\.\d*\.\d*-[S|D]-\d{5})' ${base}/docker-compose.yml ) || true

if [[ -z ${version} ]]; then
    version=$(grep -oP '(\d{2}\.\d\.\d*\.\d*)' ${base}/docker-compose.yml)
    echo ${version}

    if [[ -z ${version} ]]; then
        echo "Could not determine image version"
        exit 1
    fi
fi

link=$(grep -oP "(https.*installer\.sh)" ${base}/docker-compose.yml)

if [[ -z ${link} ]]; then
    echo "Could not determine image installer link"
    exit 1
fi

docker image build --tag ${image}:latest --build-arg INSTALLER=${link} ${PWD}

echo "Tagging image ${image} to repo ${organization}/${image} with ${version}"
docker image tag ${image}:latest ${organization}/${image}:${version}

echo "Pushing image to repo ${organization}"
docker push ${organization}/${image}:latest
docker push ${organization}/${image}:${version}


docker logout
exit 0
