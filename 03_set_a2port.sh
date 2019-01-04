#!/bin/bash
A2HTTPSPORT=${PORT:-443}
echo "Listen *:$A2HTTPSPORT" > /etc/apache2/ports.conf

ISEC=${INSECURE:-FALSE}
if [ "$ISEC" = "TRUE" ]
then
cp -f /ncapache_insecure.conf /etc/apache2/sites-available/nextcloud.conf
else
cp -f /ncapache_secure.conf /etc/apache2/sites-available/nextcloud.conf
fi
