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























