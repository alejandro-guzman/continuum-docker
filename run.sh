#!/usr/bin/env bash

${CONTINUUM_HOME}/common/bin/ctm-start-services && \
tail -f /var/continuum/log/ctm-ui.log
