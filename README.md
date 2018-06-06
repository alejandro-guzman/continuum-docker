# continuum-docker

## Purpose:
Declare environment for a Continuum image for Ossum.

## Improvements to be made:
Build a smaller image using a different base image. ex `FROM python:2.7.15-alpine3.7`  
Note: currently 950MB

## How to use
### Build image
```bash
docker image build \
    --tag continuum-production \
    --build-arg INSTALLER=<url_to_installer> \
    --file Dockerfile-continuum \
    .
```
### Run
```bash
docker containerrun \
    --rm \
    --name continuum \
    --publish 127.0.0.1:8080:8080 \
    continuum-production
```
### Compose
```bash
docker-compose pull && \
docker-compose up --build
```