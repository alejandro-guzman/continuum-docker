#!/usr/bin/env bash
set -ex

base="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
username=continuumserviceuser
organization=cycletime
image=continuum
dockerfile=${base}/prod/Dockerfile
dockercompose=${base}/prod/docker-compose.yml

# Some identifier, in our case the __PINUMBER of a run that help distinguish
# this version from another of the same branch
if [ -n $1 ]; then
    echo "Build number passed: $1"
    build=$1
fi

if [[ -n $2 && $2 == "force-image-version" ]]; then
    echo "Using image version"
    force_image_version=true
fi

echo "Logging into Docker as ${username}"
cat ${HOME}/.docker/continuumserviceuser-pw \
    | docker login -u ${username} --password-stdin \
    || true

if [ -z $force_image_version ]; then
    # Try to find the installer link in docker-compose.yml. If it's not located
    # there then we can fall back to the hardcoded official version in the image
    link=$(grep -oP "(https.*installer\.sh)" ${dockercompose} || true)
    if [ -z ${link} ]; then
        echo "Could not determine installer link from ${base}/prod/docker-compose.yml"
        exit 1
    fi

    echo "Getting version from ${base}/prod/docker-compose.yml"

    # Is this a feature branch
    version=$(grep -oP '(\d{2}\.\d\.\d*\.\d*-[S|D]-\d{5})' <<< ${link} || true)
    echo $version

    if [ -z ${version} ]; then
        # Is this a development or master branch?
        version=$(grep -oP '(\d{2}\.\d\.\d*\.\d*)' <<< ${link} || true)
    fi
else
    version=$(grep -oP '(ENV CONTINUUM_VERSION .*)' ${dockerfile} | cut -d " " -f 3)
fi

if [ -z ${version} ]; then
    echo "Could not determine image version"
    exit 1
fi

if [ -n ${build} ]; then
    version="${version}-${build}"
fi

echo ${version}

dockerfile=${base}/prod/Dockerfile

if [ -z $force_image_version ]; then
    docker image build --file ${dockerfile} --tag ${image}:latest --build-arg INSTALLER=${link} ${PWD}
else
    docker image build --file ${dockerfile} --tag ${image}:latest ${PWD}
fi

echo "Tagging image ${image} to repo ${organization}/${image} with ${version}"
docker image tag ${image}:latest ${organization}/${image}:${version}

echo "Pushing image to repo ${organization}"
docker push ${organization}/${image}:latest
docker push ${organization}/${image}:${version}


docker logout
exit 0
