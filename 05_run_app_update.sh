#!/bin/bash
UPDT_APPS=${AUTO_UPDATE_APPS:-FALSE}
if [ "$UPDT_APPS" = "TRUE" ]
then
sudo -u www-data php --define apc.enable_cli=1 /var/www/html/occ app:update --all -vvv > /dev/stdout
fi
