#!/bin/bash
# Backup de la base

LOG=/home/ec2-user/export-db.log
EXPORT=/home/ec2-user/buenacompra-$(/usr/bin/date +"%Y-%m-%d").sql.gz

echo "$(/usr/bin/date +"%Y-%m-%d %T") Comienzo del export..." >> $LOG
/usr/bin/mysqldump -u root -p'Nanofaradio.18' buenacompra 2>${LOG} |/usr/bin/gzip -c > ${EXPORT} 2>>${LOG}
echo "$(/usr/bin/date +"%Y-%m-%d %T") Fin del export..." >> $LOG

# Borra los backups de mas de 7 días
echo "$(/usr/bin/date +"%Y-%m-%d %T") Borrado de exports viejos..." >> $LOG
/home/ec2-user/bin/borrabkp.sh
