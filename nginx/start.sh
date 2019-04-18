#!/bin/bash

export NGNIX_PORT=${PORT:=80}
echo nginx will liston on port $NGNIX_PORT
envsubst < /etc/nginx/conf.d/mysite.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'
