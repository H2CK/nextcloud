#!/bin/bash
sudo -u www-data php /var/www/nextcloud/occ upgrade -vvv >> /proc/1/fd/1 
sudo -u www-data php /var/www/nextcloud/occ maintenance:update:htaccess -vvv >> /proc/1/fd/1 
