#!/usr/bin/env bash


# This will build the image locally and pull the remaining images to run.
# Eventually is should pull the Continuum image too, I'm just iterating to
# find the best way to do that without adding more docker-composes
docker-compose -f ./../prod/docker-compose.yml build
docker-compose -f ./../testlab/docker-compose.test-bench.yml pull
