FROM php:5-apache

ENV DEBIAN_FRONTEND noninteractive
ENV SCRIPT_DIR /opt

# Install Apache2, PHP and LTB ssp
RUN apt-get update && \
    apt-get install -y \
        sudo gettext-base wget pwgen \
        libldap2-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev && \
    apt-get clean && \
    ln -fs /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/ && \
    docker-php-ext-install -j$(nproc) iconv mcrypt && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install ldap

RUN wget -O self-service-password.deb http://ltb-project.org/archives/self-service-password_1.3-1_all.deb && \
    dpkg -i --force-depends self-service-password.deb ; rm -f self-service-password.deb

# Add LSSP's Apache-config for site
ADD ["assets/config/apache2/vhost.conf", "/etc/apache2/sites-available/self-service-password.conf"]
# Add LSSP's config template
ADD ["assets/config/lssp/config.inc.php", "/usr/share/self-service-password/conf/config.inc.local.php.dist"]

# Enable LSSP in Apache Web-Server
RUN a2dissite 000-default && \
    a2ensite self-service-password

# Add scripts (i.e. entrypoint)
ADD ["assets/scripts/*", "${SCRIPT_DIR}/"]
RUN chmod -R u+x ${SCRIPT_DIR}

EXPOSE 80

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["app:start"]

