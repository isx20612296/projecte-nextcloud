/usr/bin/php /var/www/nextcloud/occ maintenance:install --database \
"mysql" --database-name "nextcloud"  --database-user "ncadmin" --database-pass \
"jupiter" --admin-user "ncadmin" --admin-pass "jupiter"

/usr/bin/php /var/www/nextcloud/occ app:install onlyoffice
/usr/bin/php /var/www/nextcloud/occ app:install richdocuments
/usr/bin/php /var/www/nextcloud/occ app:install richdocumentscode
/usr/bin/php /var/www/nextcloud/occ app:install documentserver_community
