#!/usr/bin/env bash
set -ex


echo "Script running in ${PWD}"
echo "Contents:"
ls -la

USERNAME="continuumserviceuser"
ORGANIZATION="cycletime"
IMAGE="continuum"


echo "[INFO] Logging into Docker using username ${USERNAME}"
cat ${HOME}/.docker/continuumserviceuser-pw | docker login -u ${USERNAME} --password-stdin || true

echo "Getting version from docker-compose.yml"
# Tag will be the version.revision-story_number
grep -oP '(\d{2}\.\d\.\d*\.\d*-\w-\d{5})' ./docker-compose.yml
version=$(grep -oP '(\d{2}\.\d\.\d*\.\d*-\w-\d{5})' ./docker-compose.yml)
echo $version
[ -z ${version} ] && (echo "[ERROR] Could not determine image version" && exit 1)

link=$(grep -oP "(https.*installer\.sh)" ./docker-compose.yml)
[ -z ${link} ] && (echo "[ERROR] Could not determine image installer link" && exit 1)


docker image build --tag ${IMAGE}:latest --build-arg INSTALLER=${link} ${PWD}


echo "[INFO] Tagging image ${IMAGE} to repo ${ORGANIZATION}/${IMAGE} with ${version}"
docker image tag ${IMAGE}:latest ${ORGANIZATION}/${IMAGE}:${version}


echo "[INFO] Pushing image to repo ${ORGANIZATION}"
docker push ${ORGANIZATION}/${IMAGE}:latest
docker push ${ORGANIZATION}/${IMAGE}:${version}


docker logout
exit 0
