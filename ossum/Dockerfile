# Know that this is the name of the image that is built using
# scripts/deploy.sh during CI
FROM continuum:prod

# Other examples of the available base images include:

# the official production, published image
# FROM cycletime/continuum:latest

# or a custom build locally available
# FROM continuum:S-01001


# These are static env vars that make sense for Ossum, nothing in .env
# should be oncluded in here.
ENV CONTINUUM_MONGODB_SSL true
ENV UI_LOG_LEVEL 10
ENV JOB_HANDLER_LOG_LEVEL 10
ENV REPO_POLLER_LOG_LEVEL 10
ENV BASIC_AUTH disabled
ENV TOKEN_AUTH disabled
ENV MSGHUB disabled
