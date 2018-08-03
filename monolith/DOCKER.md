# agguzman/continuum

[Find on Dockerhub](https://hub.docker.com/r/agguzman/continuum/)

Build image
```bash
link="https://continuum/installer.sh"
docker image build \
    --tag continuum \
    --build-arg INSTALLER=$link \
    --file monolith/Dockerfile \
    $PWD
```
Run container
```bash
docker container run \
    --rm \
    --name ctm \
    -v $PWD/logs:/var/continuum/log \
    -v $PWD/data:/data/db \
    -p "8080:8080" \
    -p "8083:8083" \
    continuum
```
