# Versió 4 del servidor
## Solucions i millores

Un cop implementada la web segura, ara és hora de millorar problemes de memòria amb php
i el servidor integrat d'*Onlyoffice*  `documentserver_code`.

Els fitxers `apache_php.ini` i `cli_php.ini` son fitxers de configuració de PHP per Apache i
la shell interactiva. Els dos fitxers tenen dos linies de codi que ens interessa canviar. Aquestes linies són 
les següents:

```
post_max_size = 1G
memory_limit = 1G
```

- `post_max_size` estableix el límit máxim per les dades de l'operació POST. Aquest paràmetre hauria de ser menor
que `memory_limit`.

- `memory_limit` és el límit de memòria que *un* script de php pot consumir.

Els dos valors tenien per defecte 512MB i 8MB respectivament, i han sigut canviats a 1G un cop havent estudiat les condicions del servidor real. 
Això garantitza una comunicació molt més relaxada i millora l'experiència de l'usuari.

Un cop implementada aquesta modificació, es reinica el servidor d'apache:

```
service apache2 restart
```


El servidor de documents s'ha intentat implementar anteriorment, sense molt d'èxit, però l'addició de l'aplicació al llistat
és una prova després d'haver solucionat l'incidència amb PHP i també una preparació per a la futura Versió 5.

Gràcies al servidor de documents, *Onlyoffice* podrà treballar integradament amb Nextcloud i 
garantitzar que els usuaris puguin editar documents en linia.

