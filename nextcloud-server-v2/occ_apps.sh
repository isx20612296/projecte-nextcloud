/usr/bin/php /var/www/nextcloud/occ maintenance:install --database \
"mysql" --database-name "nextcloud"  --database-user "ncadmin" --database-pass \
"jupiter" --admin-user "ncadmin" --admin-pass "jupiter"

/usr/bin/php /var/www/nextcloud/occ app:install onlyoffice
