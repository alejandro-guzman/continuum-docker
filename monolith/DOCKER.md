# agguzman/continuum

[Find on Dockerhub](https://hub.docker.com/r/agguzman/continuum/)

Build image
```bash
link="https://continuum/installer.sh"
docker image build \
    --tag continuum \
    --file monolith/Dockerfile \
    $PWD
```
Run container
```bash
docker container run \
    --rm \
    --name ctm \
    -v $PWD/monolith/logs:/var/continuum/log \
    -v $PWD/monolith/data:/data/db \
    -p "8080:8080" \
    -p "8083:8083" \
    continuum
```
