#!/bin/bash
UPDT_APPS=${AUTO_UPDATE_APPS:-FALSE}
if [ "$UPDT_APPS" = "TRUE" ]
then
sudo -u www-data php /var/www/nextcloud/occ app:update --all -vvv > /dev/stdout
fi
