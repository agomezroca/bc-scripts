#!/bin/bash
# Revisa si hay paquetes para actualizar
# Antes borra y re-crea el cache de yum


# Borra el cache de yum
sudo yum clean all >/dev/null 2>&1

# Re-Crea el cache
sudo yum makecache >/dev/null 2>&1

# Busca actualizaciones
sudo yum -y check-updates 2>/dev/null > ${HOME}/paquetes-disponibles
