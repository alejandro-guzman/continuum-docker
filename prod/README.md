# Continuum Production 
### (prod/Dockerfile)

This is a production configuration of Continuum inside a container. It does 
not include specific configuration for a particular use case, it is merely a 
base image that configuration is applied to in order to successfully run this 
image.

```bash
# Build
docker image build -t continuum:prod -f prod/Dockerfile .
```

After this image gets built with the target version, for Ossum the `
ossum/Dockerfile` will reference this image when building. That image is then 
uploaded to the registry and used in Ossum.

### (prod/docker-compose.yml)

This is experimental it's here to give a test environment for the prod image.
