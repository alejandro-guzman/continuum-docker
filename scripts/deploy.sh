#!/usr/bin/env bash
set -ex

usage() {
    echo -e "\nUsage: deploy.sh <BUILD> <LINK>"
    echo -e "  BUILD: unique identifier"
    echo -e "  LINK:  location of installer (optional, will default to versioned link in docker-compose.yml then Dockerfile) \
    \n         this will be used as the image tag\n"
}

if [[ -z $1 ]]; then
    echo "No build number passed"; usage; exit 1
fi

build_id=$1

image=continuum
organization=cycletime
username=continuumserviceuser

ossum_dockerfile=./ossum/Dockerfile
prod_dockerfile=./prod/Dockerfile
prod_dockercompose=./prod/docker-compose.yml

# ##################
# Get link
# ##################
if [[ -n $2 ]]; then
    installer_link=$2
    version=$(grep -oP '(\d{2}\.\d\.\d*\.\d*-[S|D]-\d{5})' <<< ${installer_link} || true)
    if [[ -z ${version} ]]; then
        version=$(grep -oP '(\d{2}\.\d\.\d*\.\d)' <<< ${installer_link} || true)
    fi
    if [[ -z ${version} ]]; then
        echo "Installer link must be versioned"
        exit 1a
    fi
else
    installer_link=$(grep -oP "(https.*installer\.sh)" ${prod_dockercompose} || true)
    if [[ -n ${installer_link} ]]; then
        version=$(grep -oP '(\d{2}\.\d\.\d*\.\d*-[S|D]-\d{5})' <<< ${installer_link} || true)
    else
        echo "Defaulting to installer in prod/Dockerfile"
        version=$(grep -oP '(ENV CONTINUUM_VERSION .*)' ${prod_dockerfile} | cut -d " " -f 3)
    fi
fi

if [[ -z ${version} ]]; then
    echo "Installer and version not determined"
    exit 1
fi

tag=${version}-${build_id}

# ############################
# Build, tag, publish
# ############################
docker image build --file ${prod_dockerfile} --tag continuum:prod --build-arg INSTALLER_LINK=${installer_link} --no-cache .
docker image build --file ${ossum_dockerfile} --tag ${organization}/${image}:latest --no-cache .

docker image tag ${organization}/${image}:latest ${organization}/${image}:${tag}

cat ${HOME}/.docker/continuumserviceuser-pw | docker login -u ${username} --password-stdin || true

docker push ${organization}/${image}:latest
docker push ${organization}/${image}:${tag}

docker images --quiet --filter dangling=true | xargs docker image rm || true

docker logout
