FROM ubuntu:20.04

# Set correct environment variables
ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
ENV supervisor_conf /etc/supervisor/supervisord.conf
ENV security_conf /etc/apache2/conf-available/security.conf
ENV start_scripts_path /bin

ENV NC_VERSION="20.0.7"

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
    imagemagick \
    gpsbabel \
    ssl-cert \
    ffmpeg \
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
    php-sqlite3 \
    php-tidy \
    php-xmlrpc \
    php-xsl \
    php-mbstring \
    php-mysqli \
    php-mysqlnd \
    php-pgsql \
    php-posix \
    php-opcache \
    php-apcu \
    php-redis \
    php-zip \
    php-dompdf \
    php-xml \
    php-bz2 \
    php-bcmath \
    php-gmp \
    smbclient \
    wget \
    unzip \
    sudo \
    && a2enmod ssl \
    && a2enmod rewrite \
    && a2enmod env \
    && a2enmod dir \
    && a2enmod mime \
    && a2enmod headers \
    && a2enmod setenvif \
    && a2dissite 000-default \
    && phpenmod imap \
    && mkdir /crt \
    && chmod 750 /crt \
    && openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout /crt/nextcloud.key -out /crt/nextcloud.crt -subj "/C=DE/ST=H/L=F/O=Nextcloud/OU=www.nextcloud.org/CN=nextcloud" \ 
    && chmod 640 /crt/* \
    && wget -q https://download.nextcloud.com/server/releases/nextcloud-${NC_VERSION}.zip -O /tmp/nextcloud.zip \
    && unzip -d /tmp/ -o /tmp/nextcloud.zip \
    && rm -Rf /var/www/html \
    && mv /tmp/nextcloud /var/www/nextcloud \
    && chown -R www-data:www-data /var/www/nextcloud \
    && find /var/www/nextcloud/ -type d -exec chmod 750 {} \; \
    && find /var/www/nextcloud/ -type f -exec chmod 640 {} \; \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/* \
    && groupadd docker-data \
    && usermod -a -G docker-data,adm www-data

COPY supervisord.conf ${supervisor_conf}
COPY security.conf ${security_conf}
COPY 01_user_config.sh ${start_scripts_path}
COPY 02_auto_update.sh ${start_scripts_path}
COPY 03_set_a2port.sh ${start_scripts_path}
COPY 04_run_occ_commands.sh ${start_scripts_path}
COPY 05_run_app_update.sh ${start_scripts_path}

COPY start.sh /start.sh
COPY policy.xml /etc/ImageMagick-6/policy.xml
RUN chmod +x ${start_scripts_path}/01_user_config.sh \
    && chmod +x ${start_scripts_path}/02_auto_update.sh \
    && chmod +x ${start_scripts_path}/03_set_a2port.sh \
	&& chmod +x ${start_scripts_path}/04_run_occ_commands.sh \
    && chmod +x ${start_scripts_path}/05_run_app_update.sh \
    && chmod +x /start.sh

CMD ["/start.sh"]
       
#Add Apache configuration
COPY php.ini /etc/php/7.4/apache2/php.ini
COPY nextcloud.conf /etc/apache2/sites-available/nextcloud.conf
RUN chmod 644 /etc/apache2/sites-available/nextcloud.conf \
	&& a2ensite nextcloud

COPY nextcloud.conf /ncapache_secure.conf
COPY nextcloud_insecure.conf /ncapache_insecure.conf
	
COPY nextcloud.cron /etc/cron.d/nextcloud

VOLUME /var/www/nextcloud/data /var/www/nextcloud/config /var/www/nextcloud/capps

EXPOSE 443/tcp
