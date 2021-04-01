#!/bin/bash
# Nextcloud server

apt -y install apache2 mariadb-server libapache2-mod-php7.4 && echo "Basics OK"
apt -y install php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl && echo "PHP OK"
apt -y install php7.4-gmp php7.4-bcmath php-imagick php7.4-xml php7.4-zip && "Extra PHP OK"

cp /opt/docker/nextcloud.conf /etc/apache2/sites-available/

/etc/init.d/mysql start

# Series de comandes al MariaDB
mysql -u root -p '' < sqlconfig.sql

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

/bin/bash
