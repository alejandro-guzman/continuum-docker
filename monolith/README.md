# Continuum (all in one)
[Find on Dockerhub](https://hub.docker.com/r/agguzman/continuum/)

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
