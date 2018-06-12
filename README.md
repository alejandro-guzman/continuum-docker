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
docker container run \
    --rm \
    --name continuum \
    --publish 127.0.0.1:8080:8080 \
    --publish 127.0.0.1:8083:8083 \
    continuum-production
```
### Compose
```bash
docker-compose pull && \
docker-compose up --build
```
### Development
Make sure `$CONTINUUM_HOME` points to the root of your cloned continuum repo.  
At the moment this still requires you to run the webpack dev server on your 
machine.   
`npm run server`
```bash
docker-compose pull && \
docker-compose \
    --file docker-compose-dev.yml \
    up --build
```
