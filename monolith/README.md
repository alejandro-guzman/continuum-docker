# Continuum (all in one)
[Published on Dockerhub](https://hub.docker.com/r/agguzman/continuum/)

### (monolith/Dockerfile)

This image is an all  in one solution to running Continuum. It is bundled with
Continuum and MongoDB, running in a non secure fashion. This is NOT intended 
for production. This image is intended for demonstrations.

```bash
# Build
docker image build -t continuum:monolith -f monolith/Dockerfile .
```

```bash
# Run
docker container run --rm --name continuum-monolith -p "8080:8080" -p "8083:8083" continuum:monolith
```
 ###### Notes
This may be better located in the prod or entrypoint files. I'm wondering if 
we need to keep track of a separate Dockerfiles for this use case. It does 
make the image smaller if we did not bundle MongoDB up with the prod image but it 
is more convenient.
