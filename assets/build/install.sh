#!/bin/bash
set -e

mkdir -p ${OWNCLOUD_INSTALL_DIR}

if [[ ! -f ${OWNCLOUD_BUILD_DIR}/owncloud-${OWNCLOUD_VERSION}.tar.bz2 ]]; then
  echo "Downloading ownCloud ${OWNCLOUD_VERSION}..."
  wget "https://download.owncloud.org/community/owncloud-${OWNCLOUD_VERSION}.tar.bz2" -O ${OWNCLOUD_BUILD_DIR}/owncloud-${OWNCLOUD_VERSION}.tar.bz2
fi

echo "Extracting ownCloud ${OWNCLOUD_VERSION}..."
tar -xf ${OWNCLOUD_BUILD_DIR}/owncloud-${OWNCLOUD_VERSION}.tar.bz2 --strip=1 -C ${OWNCLOUD_INSTALL_DIR}
rm -rf ${OWNCLOUD_BUILD_DIR}/owncloud-${OWNCLOUD_VERSION}.tar.bz2

# create symlink to config.php
ln -sf ${OWNCLOUD_CONF_DIR}/config.php ${OWNCLOUD_INSTALL_DIR}/config/config.php

# upload_max_filesize
(
  echo "default_charset='UTF-8'"
  echo "output_buffering=off"
) > ${OWNCLOUD_INSTALL_DIR}/.user.ini

# set directory permissions
find ${OWNCLOUD_INSTALL_DIR}/ -type f -print0 | xargs -0 chmod 0640
find ${OWNCLOUD_INSTALL_DIR}/ -type d -print0 | xargs -0 chmod 0750
chown -R root:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/
chown -R ${OWNCLOUD_USER}:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/apps/
chown -R ${OWNCLOUD_USER}:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/config/
chown -R ${OWNCLOUD_USER}:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/themes/
chown root:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/.htaccess
chmod 0644 ${OWNCLOUD_INSTALL_DIR}/.htaccess
chown root:${OWNCLOUD_USER} ${OWNCLOUD_INSTALL_DIR}/.user.ini
chmod 0644 ${OWNCLOUD_INSTALL_DIR}/.user.ini
