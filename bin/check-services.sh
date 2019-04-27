#!/bin/bash
# Chequea si los servicios de buenacompra estan activos
# MariaDB, nginx y php-fpm

# Funcion para chequear el status de un servicio
check_svc(){
service=$1

/usr/bin/systemctl is-active $service

}

# Notifica alguna condicion erronea

manda_mail() {
SUBJECT=$1
MESSAGE=$2

echo "$MESSAGE" | /usr/local/bin/sendEmail -f alerta@idex.com.ar -t agustin.gomez.roca@gmail.com -t apicco@idex.com.ar -u ${SUBJECT}
}

# Archivos de log a analizar
access_log=/var/log/nginx/access.log
error_log=/var/log/nginx/error.log

fecha=$(/usr/bin/date "+%Y-%m-%d %T")

# Releva el status de los servicios

nginx_status=$(check_svc nginx)
php_status=$(check_svc php71-php-fpm)
mariadb_status=$(check_svc mariadb)

last_min_access=$(/usr/bin/date "+%d/%b/%Y:%H:%M" --date="now - 1 minute")
requests=$(/usr/bin/awk -vlast_min=$last_min_access 'BEGIN{count=0};($4 ~ last_min) {count=count+1};END{print count}' $access_log)

last_min_error=$(/usr/bin/date "+%H:%M" --date="now - 1 minute")
errors=$(/usr/bin/awk -vlast_min="$last_min_error:" 'BEGIN{count=0}; ($2 ~ last_min) {count=count+1};END{print count}' $error_log)

memfree=$(/usr/bin/awk '/MemFree/ {print $2}' /proc/meminfo)
swpfree=$(/usr/bin/awk '/SwapFree/ {print $2}' /proc/meminfo)


if [ "${nginx_status}" != "active" -o "${php_status}" != "active" -o "${mariadb_status}" != "active" ]
then
        SUBJECT="Servicios buenacompra"
        MESSAGE="Alguno de los servicios no estan activos:

Nginx: $nginx_status
PHP: $php_status
MariaDB: $mariadb_status

Memoria Libre: $memfree
Swap Libre: $swpfree

HTTP Requests: $requests
HTTP Errors: $errors


Verificar el sistema."

        manda_mail "${SUBJECT}" "${MESSAGE}"
fi

#echo "$fecha   Nginx:${nginx_status}   php-fpm:${php_status}   MariaDB:${mariadb_status}       MemFree:$memfree        SwapFree:$swpfree      Requests:$requests      Errors:$errors"

echo "$fecha    ${nginx_status} ${php_status}   ${mariadb_status}       ${memfree}      ${swpfree}      ${requests}     ${errors}"
