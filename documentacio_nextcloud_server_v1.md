# Versió 1 del servidor

## Servidor Nextcloud bàsic

El primer pas que vam dur a terme va ser fer una instalació del servidor amb poca cosa per veure com funcionava. Seguint el manual d'administrador que proporciona Nextcloud.
En aquesta versió es va probar només amb l'anomenat __LAMP stack__ (Linux, Apache, MariaDB, PHP), tot això s'instalarà en un contenidor Ubuntu 20.04 LTS.

En el Dockerfile comencem per instal·lar utilitats com apt-utils, vim, wget, nmap, iproute2, less, curl, gpg. Després ja es comencen a instal·lar els programes necessaris mencionats abans: apache2, mariadb-server i tots els moduls de PHP que el manual de Nextcloud indica com a moduls PHP mínims per al bon funcionament del servidor.

El següent pas és crear el VirtualHost que ens donarà accés al servidor des del navegador seguint l'exemple del manual es construeix el VirtualHost al fitxer nextcloud.conf.

Un cop creat el fitxer del VirtualHost ja creem el script startup.sh que farà tot el procés d'instal·lació. Al startup el primer pas és posar el fitxer nextcloud.conf que conté el VirtualHost al directori _/etc/apache2/sites-available_ i activar-lo amb l'ordre __a2ensite__.

A continuació s'engega el MariaDB on al probar-lo per primera vegada ens trobem que hi ha molta configuració que s'ha de fer durant l'execució del startup i per tant s'ha de crear un altre arxiu anomenat sqlconfig.sql on es crea un usuari, la database i se li donen tots els privilegis sobre la database a l'usuari acabat de crear.

Un cop solucionat aquest problema d'automatització continuem provant el startup, es fa un wget del paquet Nextcloud referent a la versió 21 .sha256, es verifica el SHA256sum, es fa el mateix amb el paquet .asc i la verificació amb gpg. Un cop fetes totes les verificacions es fa un tar del paquet per descomprimir-lo, un cop acabat el tar es copia tot el directori que s'acaba de crear al direcori __/var/www/__, a aquest directori li fan falta dos modificacions més, primer cal fer-li un chmod de 775 i un chown a l'usuari i grup www-data.

Una ultima cosa a afegir és la zona horaria que es demana durant la instal·lació i per tant al Dockerfile s'afegeix una linia que crea un link simbòlic de __/usr/share/zoneinfo/Europe/Madrid__ a __/etc/localtime__ i d'aquesta manera ja només cal reiniciar el servei apache2.

Ara el servidor ja està instal·lat i està operatiu, només cal editar el fitxer _/etc/hosts_ afegint la ip del docker i l'alias indicat al fitxer del VirtualHost.

Amb aquesta instal·lació del servidor Nextcloud per accedir a través del navegador caldra posar __localhost/nextcloud__ això porta a una pàgina on caldrà indicar la database i l'usuari de MariaDB. Al acabar aquest procès apreix el login on s'introdueixen les dades de l'administrador, en aquest cas __ncadmin__ i ja entrarem al __Dashboard__ de l'usuari, a partir d'aquí l'usuari pot accedir als seus fitxers, a la configuració del servidor, a la botiga d'aplicacions, etc.