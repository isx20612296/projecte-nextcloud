# Autenticació d'usuaris per ldap

## Container de ldap simulant una classe

Un cop el servidor ja ens ha funcionat i amb les aplicacions requerides operatives al 100%,
decidim aplicar un mètode d'autenticació que vagi més enllà del que ofereix Nextcloud.

Ja que aquest curs hem aprés a utilitzar ldap, aprofitem els coneiexments obtinguts per implementar
al servidor Nextcloud el sistema d'autenticació per ldap creant nosaltres mateixos un container amb una base de
dades propia. La nostra idea és simular una classe i els seus professors, en total seran 10 alumnes i 5 professors.

El primer de tot és crear el Dockefile on s'insta·larà ldap

Contingut del fitxer

~~~
FROM fedora:27
RUN dnf -y install procps openldap-clients openldap-servers
RUN mkdir /opt/docker
COPY * /opt/docker/
RUN chmod +x /opt/docker/install.sh /opt/docker/startup.sh
WORKDIR /opt/docker
EXPOSE 389
CMD ["/opt/docker/startup.sh"]
~~~

</br></br>

Amb això ja ens podem possar a configurar la base de dades que tindra una base que permetrà reconeixer que és per
al servidor de Nxetcloud.

Contingut del fitxer **ldap.conf**

~~~
# LDAP Defaults
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

BASE	dc=edt,dc=nextcloud,dc=org
URI	ldap://localhost

#SIZELIMIT	12
#TIMELIMIT	15
#DEREF		never

#TLS_CACERTDIR /etc/openldap/certs
TLS_CACERT /opt/docker/CA.pem

# Turning this off breaks GSSAPI used with krb5 when rdns = false
SASL_NOCANON	on
~~~

</br></br>

El següent pas serà crear els certificats que faran que la base de dades ldap sigui segura, aquesta vegada,
a diferència del que passa amb el VirtualHost de Nextcloud, els certificats poden ser autosignats ja que ningú els
ha de verificar. Un fitxer molt important a la hora de fer els cerificats del servidor és el de les extensions
que serà el que indicarà com es podrà establir connexió amb la base de dades.

Contingut del fitxer ext.alternate.conf

~~~
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth
subjectAltName=IP:172.17.0.2,IP:127.0.0.1,email:copy,URI:ldaps://ldap.edt.org
~~~

</br></br>

Un cop es tenen els certificats cal configurar TLS, la *database config*, la *database mdb* i la *database monitor*

Contingut del fitxer slapd.conf

~~~
# See slapd.conf(5) for details on configuration options.
# This file should NOT be world readable.
#

#include	/etc/openldap/schema/corba.schema
include		/etc/openldap/schema/core.schema
include		/etc/openldap/schema/cosine.schema
#include	/etc/openldap/schema/duaconf.schema
#include	/etc/openldap/schema/dyngroup.schema
include		/etc/openldap/schema/inetorgperson.schema
#include	/etc/openldap/schema/java.schema
#include	/etc/openldap/schema/misc.schema
include		/etc/openldap/schema/nis.schema
include		/etc/openldap/schema/openldap.schema
#include	/etc/openldap/schema/ppolicy.schema
include		/etc/openldap/schema/collective.schema

# Allow LDAPv2 client connections.  This is NOT the default.
allow bind_v2
pidfile		/var/run/openldap/slapd.pid
TLSCACertificateFile        /etc/openldap/certs/CA.pem
TLSCertificateFile          /etc/openldap/certs/server.pem
TLSCertificateKeyFile       /etc/openldap/certs/serverkey.pem
TLSVerifyClient       never
TLSCipherSuite        HIGH:MEDIUM:LOW:+SSLv2
#argsfile	/var/run/openldap/slapd.args

#-------------------------------------------------
database config
rootdn "cn=Sysadmin,cn=config"
rootpw {SSHA}JGzCfrm+TvKfHtbpjPdz3YCVYpqUbTVY
#passwd syskey
# -------------------------------------------------
database mdb
suffix "dc=edt,dc=nextcloud,dc=org"
rootdn "cn=Manager,dc=edt,dc=nextcloud,dc=org"
rootpw secret
directory /var/lib/ldap
index objectClass eq,pres
access to * by self write by * read
# ----------------------------------------------------------------------
database monitor
access to * by * none
~~~

</br></br>

Ara que ja tenim les configuracions preparades cal crear les dades que s'insertaran, tant l'arrel,
com les organitzacions, com els grups i els usuaris. Tot això s'especifica junt en un fitxer anomenat nc.ldif


El fragment següent correspon a la part on s'especifica l'arrel i les *Organitzational Units*

~~~
# -----------------------------------------------

dn: dc=edt,dc=nextcloud,dc=org
dc: edt
description: Base de dades LDAP dels membres de Nextcloud
objectClass: dcObject
objectClass: organization
o: edt.nextcloud.org

dn: ou=users,dc=edt,dc=nextcloud,dc=org
ou: users
description: Usuaris de Nextcloud
objectclass: organizationalunit

dn: ou=groups,dc=edt,dc=nextcloud,dc=org
ou: groups
description: Grups del Nextcloud
objectclass: organizationalunit

# -----------------------------------------------
~~~

</br></br>

En aquesta següent part s'indiquen els usuaris que després s'especificaran com a usuaris del grup de professors.

~~~
# ---------- Professors --------------------------
dn: uid=eduard,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Eduard
sn: Canet
ou: users
uid: eduard
uidNumber: 5201
gidNumber: 602
homeDirectory: /tmp/home/eduard
userPassword: {SSHA}4Dw7GeOzkjqAt92EGghrOeiDGoPZRBOs

dn: uid=maribel,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Maribel
sn: Espada
ou: users
uid: maribel
uidNumber: 5202
gidNumber: 602
homeDirectory: /tmp/home/maribel
userPassword: {SSHA}RQAO5W9gKmbHVG9INBjmnZcVPib0YnWu

dn: uid=ainhoa,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Ainhoa
sn: Zaldua
ou: users
uid: ainhoa
uidNumber: 5203
gidNumber: 602
homeDirectory: /tmp/home/ainhoa
userPassword: {SSHA}+gs+3K1eT9R7sUt+HnXDyuVVPlJlf9h6

dn: uid=montse,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Montse
sn: Soler
ou: users
uid: montse
uidNumber: 5204
gidNumber: 602
homeDirectory: /tmp/home/montse
userPassword: {SSHA}gegM+PafbuCg+Zg0G1wq+wU58uLaJSBB

dn: uid=victor,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Victor
sn: Hernandez
ou: users
uid: victor
uidNumber: 5205
gidNumber: 602
homeDirectory: /tmp/home/victor
userPassword: {SSHA}IHkEimROQSVjgXkp6RHIe+bqxw3z4Qdq

# ------------------------------------------------
~~~

</br></br>

El proper fragment de codi correspon als usuaris que després s'especificaran com a usuaris del grup d'alumnes.

~~~
# --------- Alumnes --------------------------------

dn: uid=mark,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Mark
sn: Santiago
ou: users
uid: mark
uidNumber: 5001
gidNumber: 601
homeDirectory: /tmp/home/mark
userPassword: {SSHA}AHDGtAyvB+m08nfzgCXXCpT7Wj5Xl/bc

dn: uid=diego,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Diego
sn: Sanchez
ou: users
uid: diego
uidNumber: 5002
gidNumber: 601
homeDirectory: /tmp/home/diego
userPassword: {SSHA}7sdVmGM9IJPHXrlTuB1XTNZFTKhn4CY/

dn: uid=christian,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Christian
sn: Manalo
ou: users
uid: christian
uidNumber: 5003
gidNumber: 601
homeDirectory: /tmp/home/christian
userPassword: {SSHA}miStgAV1YPGIoPm62pJV//qlv/vbtGVR

dn: uid=javier,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Javier
sn: Moyano
ou: users
uid: javier
uidNumber: 5004
gidNumber: 601
homeDirectory: /tmp/home/javier
userPassword: {SSHA}wmNL/oBT0SjziTg64seJbuHI8CqB+WnW


dn: uid=roberto,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Roberto
sn: Martinez
ou: users
uid: roberto
uidNumber: 5005
gidNumber: 601
homeDirectory: /tmp/home/roberto
userPassword: {SSHA}nq/PDuYqveb5zqe9M+wxIpy3Tedq1mnC

dn: uid=alejandro,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Alejandro
sn: Lopez
ou: users
uid: alejandro
uidNumber: 5006
gidNumber: 601
homeDirectory: /tmp/home/alejandro
userPassword: {SSHA}5HhVaTCHRPjH5E0TMmaU1/bBLlmChBg/

dn: uid=mati,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Mati
sn: Vizcaino
ou: users
uid: mati
uidNumber: 5007
gidNumber: 601
homeDirectory: /tmp/home/mati
userPassword: {SSHA}sUaeGYrBYFHin1ZdJRLGYpZdZLfNKglt

dn: uid=carles,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Carles
sn: Grillo
ou: users
uid: carles
uidNumber: 5008
gidNumber: 601
homeDirectory: /tmp/home/carles
userPassword: {SSHA}QMQBiKbthdyXddg6Jiw4aTCPW3/aynt0 

dn: uid=andreu,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Andreu
sn: Pasalamar
ou: users
uid: andreu
uidNumber: 5009
gidNumber: 601
homeDirectory: /tmp/home/andreu
userPassword: {SSHA}AGc/MSO6J3CD6jPXW3j7sg5QGfhTUhvg

dn: uid=hicham,ou=users,dc=edt,dc=nextcloud,dc=org
objectclass: posixAccount
objectclass: inetOrgPerson
cn: Hicham
sn: Varo
ou: users
uid: hicham
uidNumber: 5010
gidNumber: 601
homeDirectory: /tmp/home/hicham
userPassword: {SSHA}dWyBQOcXoVNOkbWA6T5PiW7iPV7h3RJf


# --------------------------------------------------
~~~

</br></br>

La ultima part del fitxer és en la que es declaren els grups i quins usuaris pertanyen a cada un d'aquest grups.

~~~
# ---------- Grups ------------------------------

dn: cn=admin,ou=groups,dc=edt,dc=nextcloud,dc=org
cn: admin
gidNumber: 600
description: Grup d'administradors
memberUid: carles
memberUid: andreu
objectclass: posixGroup

dn: cn=students,ou=groups,dc=edt,dc=nextcloud,dc=org
cn: students
gidNumber: 601
description: Grup d'alumnes
memberUid: mark
memberUid: christian
memberUid: diego
memberUid: javier
memberUid: roberto
memberUid: alejandro
memberUid: mati
memberUid: carles
memberUid: andreu
memberUid: hicham
objectclass: posixGroup

dn: cn=teachers,ou=groups,dc=edt,dc=nextcloud,dc=org
cn: teachers
gidNumber: 602
description: Grup de professors
memberUid: eduard
memberUid: maribel
memberUid: ainhoa
memberUid: montse
memberUid: victor
objectclass: posixGroup

# -----------------------------------------------
~~~

</br><br>

Per acabar amb la configuració del contenidor ldaps ja només cal el fitxer install.sh on es fa la copia dels fitxers
al directori corresponent i s'implementa la configuració de la base de dades i els usuaris.

Contingut del fitxer install.sh

~~~
cp  /opt/docker/ldap.conf /etc/openldap/ldap.conf
mkdir /etc/openldap/certs
cp /opt/docker/CA.pem /etc/openldap/certs/.
cp /opt/docker/server.pem /etc/openldap/certs/.
cp /opt/docker/serverkey.pem  /etc/openldap/certs/.

rm -rf /etc/openldap/slapd.d/*
rm -rf /var/lib/ldap/*
cp /opt/docker/DB_CONFIG /var/lib/ldap
slaptest -F /etc/openldap/slapd.d -f /opt/docker/slapd.conf
slapadd -F /etc/openldap/slapd.d -l /opt/docker/nc.ldif
chown -R ldap.ldap /etc/openldap/slapd.d
chown -R ldap.ldap /var/lib/ldap
~~~

</br></br></br></br>

***

## Configuració a Nextcloud per comunicar-se amb el contenidor ldap

El primer que s'ha de fer és instalar el modul php de ldpa

~~~
apt install php-ldap
~~~




















































