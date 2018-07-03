#!/usr/bin/env bash

while true; do sleep 1; done
${CONTINUUM_HOME}/client/bin/ctm-start-services && \
tail -f /var/continuum/log/ctm-ui.log
