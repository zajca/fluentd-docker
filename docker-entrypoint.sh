#!/bin/bash -e
TEMPLATE_FILE=/templates/td-agent.conf.j2

if [ -f $TEMPLATE_FILE ]; then
    j2 $TEMPLATE_FILE > /etc/td-agent/td-agent.conf
fi

exec "$@"