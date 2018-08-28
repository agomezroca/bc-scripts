#!/bin/bash
# Crea Snapshot de la instancia de buenacompra
# VolumeID: vol-0fed5c37b7729fdd4
# Description: AAAA/MM/DD-HH:MM:SS-Ultimo-Magento-Linux-2-Nginx
# 
# NOTA:
# Requiere un paquete llamado jq
# Instalar con: yum -y install jq

SNAPDATE="$(/usr/bin/date +%Y%m%d-%T)"
DESC="${SNAPDATE}-Ultimo-Magento-Linux-2-Nginx"
VOLID="vol-055a45dabbee166e3"
SNAPDIR=/var/tmp/snapshots-buenacompra
SNAPJSON=${SNAPDIR}/snapshot-${SNAPDATE}.json
SNAPLIST=${SNAPDIR}/snaplist
SNAPERR=${SNAPDIR}/snaperr
MAXSNAPSHOT=2

# SYNOPSIS
#             create-snapshot
#           [--description <value>]
#            --volume-id <value>
#           [--dry-run | --no-dry-run]
#           [--cli-input-json <value>]
#           [--generate-cli-skeleton <value>]
# 

if [ ! -d "$SNAPDIR" ]
then
	/bin/mkdir -p "$SNAPDIR"
fi

echo "Creando Snapshot: ${SNAPJSON}"
/usr/bin/aws ec2 create-snapshot --volume-id "${VOLID}" \
                                 --description "${DESC}" \
                                 > ${SNAPJSON} 2>${SNAPERR}
                                 #--tag-specifications "ResourceType=snapshot,Tags=[{Key=Name,Value=${DESC}}]" \

if [ "$?" -ne 0 ]
then
	echo "Error en la creacion de la snapshot."
	/cat/cat ${SNAPERR}
	/bin/rm -f ${SNAPJSON} 2>/dev/null
	exit
fi

SNAPSHOTS=$(/bin/ls ${SNAPDIR}/snapshot-* |/bin/wc -l)

while [ "${SNAPSHOTS}" -gt "${MAXSNAPSHOT}" ]
do
	OLDESTSNAP=$(/bin/ls -tr1 ${SNAPDIR}/snapshot-* |/bin/head -1)
	SnapshotId=$(/usr/bin/awk '/SnapshotId/ {print $NF}' ${OLDESTSNAP}| /bin/tr -d \")
	echo "Borrando ${OLDESTSNAP}..."
	/usr/bin/aws ec2 delete-snapshot --snapshot-id ${SnapshotId}  2>${SNAPERR}
	if [ "$?" -eq 0 ]
	then
		/bin/rm -f ${OLDESTSNAP}
	else
		echo "Error borrando snapshot."
		/bin/cat ${SNAPERR}
	fi


	SNAPSHOTS=$(/bin/ls ${SNAPDIR}/snapshot-* |/bin/wc -l)
done

	
Description=$(/usr/bin/awk '/Description/ {print $NF}' ${SNAPJSON})

