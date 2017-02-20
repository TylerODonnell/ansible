#! /usr/bin/env bash

cd /opt/certbot
./certbot-auto renew --webroot -w /home/appuser/app/current/public --post-hook "service nginx reload"
