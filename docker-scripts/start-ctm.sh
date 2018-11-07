#!/usr/bin/env bash

echo "Starting Continuum services"
${CONTINUUM_HOME}/common/bin/ctm-start-services && tail -f /var/continuum/log/ctm-ui.log
