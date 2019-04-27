#!/bin/bash
# dbprod2test.sh
# Pasa la base de datos de produccion a test
#
# buenacompra (52.4.31.216) --> bcprueba (192.168.1.140)

# Pasos
# - bajar nginx de prod
# - generar el export de buenacompra en prod
# - levantar nginx de prod
# - traer el dump
# - borra el dump en prod
# - bajar nginx de test
# - borrar la base de test
# - crea la base de test vacia
# - importar la base de test
# - levantar nginx de test
# - borra el dump en test
# - reconfigura el sitio
#   - reconfigura la url
#   - reconfigura el protocolo para admin (http)

try() {
linea=$1
pid=$$
shift
#set -x

$*  > /tmp/${pid} 2>/tmp/${pid}.err


if [ "$?" -ne 0 ]
then
        echo "Linea Nro.: $linea"
        echo "Fallo: $*"
        cat /tmp/${pid}.err
        rm -f /tmp/${pid} /tmp/${pid}.err
        exit
else
        echo "Ok"
        cat /tmp/${pid}
        rm -f /tmp/${pid} /tmp/${pid}.err
fi

}

create_buenacompra() {
echo "create database buenacompra;" |mysql -u root -p'npmmamt1'
}

drop_buenacompra() {
echo "drop database buenacompra;" |/usr/bin/mysql -u root -p'npmmamt1' && touch /dev/null
}

import_buenacompra() {
/usr/bin/mysql -u root -p'npmmamt1' buenacompra < $1
}

# Variables
MAGE_HOME="/var/www/html"
SSHCMD="ssh -i $HOME/.ssh/bc_NVirginia.pem ec2-user@buenacompra "
SCPCMD="scp -i $HOME/.ssh/bc_NVirginia.pem -C ec2-user@buenacompra"
MYSQLDUMP="/usr/bin/mysqldump"
TESTSITE="http://www.bc-lab.com.ar/"
DUMPFILE=/tmp/dump.sql

# - bajar nginx de prod

echo "Bajando nginx de prod..."
try ${LINENO} ${SSHCMD} /usr/bin/sudo /usr/bin/systemctl stop nginx

# - generar el export de buenacompra en prod

echo "Generando el dump en prod..."
try ${LINENO} ${SSHCMD} /usr/bin/mysqldump  -u buenacompra -p\'Nanofaradio.18\' buenacompra \> ${DUMPFILE}

# - levantar nginx de prod

echo "Levantando el nginx de prod..."
try ${LINENO} ${SSHCMD} /usr/bin/sudo /usr/bin/systemctl start nginx

# - traer el dump

echo "Trayendo el mysqldump a test..."
try ${LINENO} ${SCPCMD}:${DUMPFILE} ${DUMPFILE}

# - borra el dump en prod

echo "Borrando el dump en prod..."
try ${LINENO} ${SSHCMD} /usr/bin/rm -f ${DUMPFILE}

# - bajar nginx de test

echo "Bajando el nginx de test..."
try ${LINENO} sudo systemctl stop nginx

# - borrar la base de test

echo "Borra la base de datos de test...."

try ${LINENO} drop_buenacompra

# - crea la base de test vacia
echo "Crea la base de test vacia..."
try ${LINENO} create_buenacompra

# - importar la base de test

echo "Importando la base en test..."
try ${LINENO} import_buenacompra ${DUMPFILE}

# - levantar nginx de test

echo "Levantando nginx en test..."
try ${LINENO} sudo systemctl start nginx

# - borra el dump en test

echo "Borra el dump en test..."
try ${LINENO} /usr/bin/rm -f ${DUMPFILE}

echo "Reconfigura el sitio para entrar con ${TESTSITE}..."
# - reconfigura el sitio
try ${LINENO} php ${MAGE_HOME}/bin/magento setup:store-config:set --base-url=${TESTSITE}

echo "Reconfigura el protocolo http para admin..."
# - reconfigura el protocolo para admin
try ${LINENO} php ${MAGE_HOME}/bin/magento setup:store-config:set --use-secure-admin=0

echo "Reindexando..."

echo " *** indexer:reindex *** "
try ${LINENO} php ${MAGE_HOME}/bin/magento indexer:reindex


echo "Limpiando el cache..."

echo " *** cache:clean ***"

try ${LINENO} php ${MAGE_HOME}/bin/magento cache:clean

echo " *** cache:flush ***"

try ${LINENO} php ${MAGE_HOME}/bin/magento cache:flush
