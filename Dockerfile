FROM ubuntu:bionic

# Set correct environment variables
ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV supervisor_conf /etc/supervisor/supervisord.conf
ENV start_scripts_path /bin

# Update packages from baseimage
RUN apt-get update -qq
# Install and activate necessary software
RUN apt-get upgrade -qy && apt-get install -qy \
    apt-utils \
    cron \
    supervisor \
    apache2 \
    apache2-utils \
    libexpat1 \
    ssl-cert \
    php \
    libapache2-mod-php \
    php-mysql \
    php-curl \
	php-calendar \
	php-ctype \
	php-date \
	php-dom \
	php-exif \
	php-fileinfo \
	php-ftp \
    php-gd \
	php-iconv \
    php-intl \
    php-pear \
    php-imagick \
    php-imap \
	php-json \
	php-ldap \
    php-memcache \
    php-pspell \
    php-recode \
    php-sqlite3 \
    php-tidy \
    php-xmlrpc \
    php-xsl \
    php-mbstring \
	php-mysqli \
	php-mysqlnd \
	php-posix \
    php-gettext \
    php-opcache \
    php-apcu \
	php-redis \
	php-zip \
	php-dompdf \
	php-xml \
	smbclient \
	wget \
    unzip \
    && a2enmod ssl \
    && a2enmod rewrite \
    && a2enmod env \
	&& a2enmod dir \
	&& a2enmod mime \
	&& a2enmod headers \
    && a2dissite 000-default \
	&& phpenmod imap \
    && mkdir /crt \
    && chmod 750 /crt \
    && openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout /crt/nextcloud.key -out /crt/nextcloud.crt -subj "/C=DE/ST=H/L=F/O=Nextcloud/OU=www.nextcloud.org/CN=nextcloud" \ 
    && chmod 640 /crt/* \
	&& sed -i.bak '/^ *upload_max_filesize/s/=.*/= 2048M/' /etc/php/7.2/apache2/php.ini \
	&& sed -i.bak '/^ *post_max_size/s/=.*/= 2058M/' /etc/php/7.2/apache2/php.ini \
    && wget -q https://download.nextcloud.com/server/releases/latest.zip -O /tmp/nextcloud.zip \
    && unzip -d /tmp/ -o /tmp/nextcloud.zip \
    && rm -Rf /var/www/html \
    && mv /tmp/nextcloud /var/www/nextcloud \
    && chown -R www-data:www-data /var/www/nextcloud \
    && chmod -R 770 /var/www/nextcloud \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/* \
    && groupadd docker-data \
    && usermod -a -G docker-data,adm www-data

COPY supervisord.conf ${supervisor_conf}
COPY 01_user_config.sh ${start_scripts_path}
COPY 02_auto_update.sh ${start_scripts_path}
COPY 03_set_a2port.sh ${start_scripts_path}

COPY start.sh /start.sh
RUN chmod +x ${start_scripts_path}/01_user_config.sh \
    && chmod +x ${start_scripts_path}/02_auto_update.sh \
    && chmod +x ${start_scripts_path}/03_set_a2port.sh \
    && chmod +x /start.sh

CMD ["/start.sh"]
       
#Add Apache configuration
COPY nextcloud.conf /etc/apache2/sites-available/nextcloud.conf
RUN chmod 644 /etc/apache2/sites-available/nextcloud.conf \
	&& a2ensite nextcloud
	
COPY nextcloud.cron /etc/cron.d/nextcloud

VOLUME /var/www/nextcloud/data /var/www/nextcloud/config /var/www/nextcloud/capp

EXPOSE 443/tcp
