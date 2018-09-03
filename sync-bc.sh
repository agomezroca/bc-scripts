#!/bin/bash
# Sincroniza el arbol de directorios del sitio buenacompra de producción con el entorno de pruebas
#

SSHCMD="/usr/bin/ssh -i $HOME/.ssh/bc_NVirginia.pem ec2-user@buenacompra "
SCPCMD="/usr/bin/scp -i $HOME/.ssh/bc_NVirginia.pem -C ec2-user@buenacompra"

# Pasos:
#
# Crea el archivo .tar.gz del /var/www/html en produccion
# Trae el archivo .tar.gz a test
# Toma backup del archivo /var/www/html/app/etc/env.php fuera del /var/www/html
# Bajar nginx, php-fpm, redis y mariadb
# Toma backup del /var/www/html completo
# Borra el /var/www/html
# extrae el .tar.gz traido de produccion
# Recupera el env.php para volver a la configuracion local
# Levanta los servicios en orden inverso: mariadb, redis, php-fpm y nginx
#
