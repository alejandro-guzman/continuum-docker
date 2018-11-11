# Continuum in Docker
[Find on Dockerhub](https://hub.docker.com/r/cycletime/continuum/)

### Purpose
`prod/Dockerfile` is the build and environment definition for Continuum. You'll find Continuum's dependencies listed including C libraries, packages, and environment variables.
Originally created for Ossum but can be used in other contexts, see [prod](./prod/README.md), [ossum](./ossum/README.md), [monolith](./monolith/README.md), and [dev](./dev)

### Using Docker Compose
This will spin up a fully working Continuum instance with a Mongo backend and persistent storage and log files using docker volumes.
This is useful for testing installers as the `docker-compose.yml` can be modified to use whatever installer you specify.
You can also use this for demo purposes as all the changes you make are persisted.
It is not recommended to use for production as a stack deployment is more appropriate. A stack file/deployment documentation will be **coming soon**!
```bash
docker-compose -f ./ossum/docker-compose.yml up --build
```
Continuum should now be available at http://localhost:8080  
Default login: _administrator/password_  

Additionally! You can spin up services for a few integrations we support.
You can use the `docker-compose.test-bench.yml` in addition with the `docker-compose.yml`.
```bash
docker-compose -f ossum/docker-compose.yml -f ossum/docker-compose.test-bench.yml up --build
```
Note: `ossum/docker-compose` is being used but ideally `prod` should be
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
docker-compose -f dev/docker-compose.yml up --build
```
Continuum should now be available at http://localhost:9000  
Default login: _administrator/password_  
Happy dev-ing!
##### How to improve Development
* Don't rely on installer to setup environment
* Better security with a dedicated app user (not sure how beneficial this 
 is in a dev environment)
* Reduce image size by using python base image instead of ubuntu
* Make configuration mountable to allow changes without needing 
to rebuild/restart.
