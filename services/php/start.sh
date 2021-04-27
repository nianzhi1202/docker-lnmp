#!/usr/bin/env bash

# start cron
service cron start

# start supervisord
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

# start php-fpm
# php-fpm
