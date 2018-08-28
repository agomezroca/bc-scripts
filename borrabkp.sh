#!/bin/bash
# Borra los backups de mas de una semana
BKPDIR=/home/ec2-user
BKPNAME='buenacompra-????-??-??.sql.gz'
#RSYNCNAME='rsync-????-??-??-??:??:??.log'
MAXEXPORTS=7

LOG="/home/ec2-user/borrabkp.log"

echo "$(date +%Y-%m-%d) - borrado de backups viejos: " >> $LOG

cd ${BKPDIR}
#/usr/bin/find . -type f -name "$BKPNAME" -mtime 7 |tee -a $LOG | xargs rm -f
EXPORTS=$(/bin/ls ${BKPDIR}/buenacompra-????-??-??.sql.gz |/bin/wc -l)

while [ "${EXPORTS}" -gt "${MAXEXPORTS}" ]
do
        OLDESTEXPORT=$(/bin/ls -tr1 ${BKPDIR}/buenacompra-????-??-??.sql.gz |/bin/head -1)
        echo "Borrando ${OLDESTEXPORT}..." >> $LOG
        /bin/rm -f ${OLDESTEXPORT} 2>/dev/null

        EXPORTS=$(/bin/ls ${BKPDIR}/buenacompra-????-??-??.sql.gz |/bin/wc -l)

done


#echo -n "$(date +%Y-%m-%d) - borrado de log de rsync viejos: " >> $LOG
#/usr/bin/find . -type f -name "$RSYNCNAME" -mtime 7 |tee -a $LOG | xargs rm -f
