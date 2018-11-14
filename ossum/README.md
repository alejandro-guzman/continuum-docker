# Continuum in Ossum
[Published on Dockerhub](https://hub.docker.com/r/cycletime/continuum/)

### (ossum/Dockerfile)

This image gets published to `hub.docker.com/r/cycletime/continuum` to an is 
used as the official image for Ossum.

```bash
# Build
docker image build -t continuum:ossum -f ossum/Dockerfile .
```

### (osssum/docker-compose.yml)

This is a convenience that stands up the Ossum image in an environment for 
developing, testing, and debugging.

```bash
docker-compose -f ./ossum/docker-compose.yml up --build
```

##### Steps to get this image in Ossum:
- Build `prod/Dockerfile` with the target version
    - Versions can be an official release (18.3.0.67, etc.), an unofficial installer 
    originating from a branch, or a local build
    - Instructions to build [are here](../prod/README.md)
- Build `ossum/Dockerfile` with a tag
    - The target version points to a local build of `prod/Dockerfile` but can 
    be changed to point to a published Continuum image in the future
        - Currently the production Continuum image does not get published
    - Instructions to build [are here](#continuum-in-ossum)
- Push the image to `hub.docker.com/r/cycletime/continuum`
- Run the [ossum-continuum](https://jenkins.test.ossum.cloud/job/ossum-continuum/) 
Jenkins job in the test ossum instance and 
[run a build with the image](https://jenkins.test.ossum.cloud/job/ossum-continuum/build?delay=0sec)

`scripts/deploy.sh` is a convenient script to build and publish the image which is 
also used by the CI server on master pushes.

