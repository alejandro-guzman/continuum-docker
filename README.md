# continuum-docker

## Purpose:
`Dockerfile` is the build and environment definition of Continuum. You'll find Ctms' current dependencies and their versions listed including C libs and environment variables.
This was originally made to provide a stable image for use with Ossum, but can also act as an easy to spin up staging instance. You can spin up an instance using `docker-compose.yml` - see section [Compose](#using-docker-compose)

## Improvements to be made:
Build a smaller image using a different base image. ex `FROM python:2.7.15-alpine3.7`

## How to use
### Building an image
This is useful if you just require a continuum image for other uses. This will not run alone as Continuum requires Mongo backend to run properly.
```bash
docker image build \
    --tag continuum-production \
    --build-arg INSTALLER=<url_to_installer> \
    --file Dockerfile \
    "$PWD"
```
Instruction on spinning up a container based on the image, again this requires a Mongo backend to be accessible.
### Run
```bash
docker container run \
    --rm \
    --name continuum \
    --publish 127.0.0.1:8080:8080 \
    --publish 127.0.0.1:8083:8083 \
    continuum-production
```

### Using Docker Compose
This will spin up a fully working Continuum instance with a Mongo backend and persistent storage and log files using docker volumes.
This is useful for testing installers as the `docker-compose.yml` can be modified to use whatever installer you specify.
You can also use this for demo purposes as all the changes you make are persisted.
It is not recommended to use for production as a stack deployment is more appropriate. A stack file/deployment documentation will be **coming soon**!
```bash
docker-compose pull && \
docker-compose up --build
```
Continuum should now be available at http://localhost:8080  
Default login: _administrator/password_  

Additionally! You can spin up services for a few integrations we support.
You can use the `docker-compose.test-bench.yml` in addition with the `docker-compose.yml`.
```bash
docker-compose \
    -f docker-compose.yml \
    -f docker-compose.test-bench.yml \
    pull && \
docker-compose \
    -f docker-compose.yml \
    -f docker-compose.test-bench.yml \
    up --build
```
* Jenkins default username is `admin` & password is logged to the console, or you can bash into the container and find it at `/var/jenkins_home/secrets/initialAdminPassword`
* Gitlab default username is `root` & password is created on initial login
* Artifactory default username is `admin` & password is `password`

Run `docker container ls` to see which ports each service is running on.

**Enjoy!**

### Setting up a development environment
You can quickly setup a development environment for Continuum. `dev/docker-compose.yml` sets up a front and backend environment base on the dependencies listed in the `dev/Dockerfile` and the `dev/package.json` and `dev/requirements.txt` for each env respectively.
This is useful as you can stand up a development environment quickly without having to install python and npm dependencies on your host machine and worrying about which versions to install.
This setup is still being tested, although everything appears to function properly.
To start make sure `$CONTINUUM_REPO` points to the root of your cloned Continuum repo.  
```bash
export CONTINUUM_REPO=/path/to/continuum/repo
```
Then start the containers.
```bash
docker-compose pull && \
docker-compose \
    --file dev/docker-compose.yml \
    up --build
```
Continuum should now be available at http://localhost:9000  
Default login: _administrator/password_  
Happy dev-ing!
#### How to improve Development
* Don't rely on installer to setup environment
* Better security with a dedicated app user (not sure how beneficial this 
 is in a dev environment)
* Reduce image size by using python base image instead of ubuntu
* Make configuration mountable to allow changes without needing 
to rebuild/restart.
