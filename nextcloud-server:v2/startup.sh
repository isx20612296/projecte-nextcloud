#!/bin/bash
# Nextcloud server

cp /opt/docker/nextcloud.conf /etc/apache2/sites-available/

/etc/init.d/mysql start

# Series de comandes al MariaDB
mysql -u root < sqlconfig.sql

echo "root:jupiter" | chpasswd

wget https://download.nextcloud.com/server/releases/nextcloud-21.0.0.tar.bz2.sha256
sha256sum -c nextcloud-21.0.0.tar.bz2.sha256 < nextcloud-21.0.0.tar.bz2


wget https://download.nextcloud.com/server/releases/nextcloud-21.0.0.tar.bz2
wget https://download.nextcloud.com/server/releases/nextcloud-21.0.0.tar.bz2.asc
wget https://nextcloud.com/nextcloud.asc
gpg --import nextcloud.asc
gpg --verify nextcloud-21.0.0.tar.bz2.asc nextcloud-21.0.0.tar.bz2

tar -xjvf nextcloud-21.0.0.tar.bz2

cp -r nextcloud /var/www
a2ensite nextcloud.conf

chmod 775 -R /var/www/nextcloud/
chown www-data:www-data /var/www/nextcloud/ -R

service apache2 start

su www-data -s /bin/bash -c '/opt/docker/occ_apps.sh'

/bin/bash
