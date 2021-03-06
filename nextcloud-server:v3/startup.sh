#!/bin/bash
# Nextcloud server



cp /opt/docker/nextcloud.conf /etc/apache2/sites-available/
mkdir /var/www/certs
cp -r /opt/docker/server.pem /var/www/certs
cp -r /opt/docker/serverkey.pem /var/www/certs

echo -e "\t \t \e[34m Engeguem el MariaDB \e[0m"
/etc/init.d/mysql start

# Series de comandes al MariaDB
mysql -u root < sqlconfig.sql

echo "root:jupiter" | chpasswd

echo -e "\t \t \e[34m Descàrrega dels fitxers \e[0m"
wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.tar.bz2
wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.tar.bz2.asc
wget https://nextcloud.com/nextcloud.asc

echo -e "\t \t \e[34m Comprovació del checksum \e[0m"
wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.tar.bz2.sha256
sha256sum -c nextcloud-21.0.1.tar.bz2.sha256 < nextcloud-21.0.1.tar.bz2
sleep 1

echo -e "\t \t \e[34m Verifiquem clau GPG \e[0m"
gpg --import nextcloud.asc
gpg --verify nextcloud-21.0.1.tar.bz2.asc nextcloud-21.0.1.tar.bz2
sleep 1

echo -e "\t \t \e[34m Extraent els arxius necessaris... \e[0m"
pv nextcloud-21.0.1.tar.bz2 | tar -xj && echo -e "\t \t \e[34m Extracció completada \e[0m"

cp -r nextcloud /var/www
a2ensite nextcloud.conf

chmod 775 -R /var/www/nextcloud/
chown www-data:www-data /var/www/nextcloud/ -R

echo -e "\t \t \e[34m Habilitant mòduls... \e[0m"
a2enmod rewrite &> /dev/null
a2enmod headers &> /dev/null
a2enmod env &> /dev/null
a2enmod dir &> /dev/null
a2enmod mime &> /dev/null
a2enmod ssl &> /dev/null
echo -e "\t \t \e[34m Mòduls habilitats \e[0m"
echo -e "\t \t \e[34m Deshabilitem pàgina principal d'Apache \e[0m"
a2dissite 000-default.conf &> /dev/null

echo -e "\t \t \e[34m Engeguem Apache \e[0m"
service apache2 start &> /dev/null

echo -e "\t \t \e[34m Apliquem configuració del Nextcloud \e[0m"
chmod +x /opt/docker/occ_apps.sh
su www-data -s /bin/bash -c '/opt/docker/occ_apps.sh'
cp /opt/docker/config.php /var/www/nextcloud/config/config.php
cp /opt/docker/cli_php.ini /etc/php/7.4/cli/php.ini
cp /opt/docker/apache_php.ini /etc/php/7.4/apache2/php.ini
echo -e "\t \t \e[34m Procés d'enjagada i configuració completat \e[0m"
sleep 1
/bin/bash
