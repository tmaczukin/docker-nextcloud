FROM sameersbn/ubuntu:16.04.20190706
MAINTAINER sameer@damagehead.com

ENV PHP_VERSION=7.0 \
    NEXTCLOUD_VERSION=15.0.4 \
    NEXTCLOUD_USER=www-data \
    NEXTCLOUD_INSTALL_DIR=/var/www/nextcloud \
    NEXTCLOUD_DATA_DIR=/var/lib/nextcloud \
    NEXTCLOUD_CACHE_DIR=/etc/docker-nextcloud

ENV NEXTCLOUD_BUILD_DIR=${NEXTCLOUD_CACHE_DIR}/build \
    NEXTCLOUD_RUNTIME_DIR=${NEXTCLOUD_CACHE_DIR}/runtime

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 14AA40EC0831756756D7F66C4F4EA0AAE5267A6C \
 && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu xenial main" >> /etc/apt/sources.list \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 8B3981E7A6852F782CC4951600A6F0A3C300EE8C \
 && echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu xenial main" >> /etc/apt/sources.list \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      nginx mysql-client postgresql-client gettext-base \
      lbzip2 \
      php${PHP_VERSION}-fpm php${PHP_VERSION}-cli php${PHP_VERSION}-gd \
      php${PHP_VERSION}-pgsql php${PHP_VERSION}-mysql php${PHP_VERSION}-curl \
      php${PHP_VERSION}-zip php${PHP_VERSION}-xml php${PHP_VERSION}-mbstring \
      php${PHP_VERSION}-intl php${PHP_VERSION}-mcrypt php${PHP_VERSION}-ldap \
      php${PHP_VERSION}-gmp php${PHP_VERSION}-apcu php${PHP_VERSION}-imagick \
 && sed -i 's/^listen = .*/listen = 0.0.0.0:9000/' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && sed -i 's/^;env\[PATH\]/env\[PATH\]/' /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
 && phpenmod -v ALL mcrypt \
 && rm -rf /var/lib/apt/lists/*

COPY assets/build/ ${NEXTCLOUD_BUILD_DIR}/
RUN bash ${NEXTCLOUD_BUILD_DIR}/install.sh

COPY assets/runtime/ ${NEXTCLOUD_RUNTIME_DIR}/
COPY assets/tools/ /usr/bin/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

VOLUME ["${NEXTCLOUD_INSTALL_DIR}/apps"]
VOLUME ["${NEXTCLOUD_DATA_DIR}"]
WORKDIR ${NEXTCLOUD_INSTALL_DIR}
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["app:nextcloud"]

EXPOSE 80/tcp 9000/tcp
