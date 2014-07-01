#!/bin/bash

# TODO : De todo :)
# Al menos falta verificar si está instalado debootstrap, live-build, etc

# Requisitos :
# - Que haya espacio disponible
# - Que el usuario sea root


# Verificamos que haya al menos 6GB libres

LIBRE=`df -B 1G . | tail -1 | awk '{print $4}'`
if [[ $LIBRE -lt 6 ]]; then
	echo "No hay al menos 6GB Libres"
	exit 1
fi


# Verificamos que el usuario sea root

if [[ "`whoami`" != "root" ]]; then
	echo "Debe ser root lamentablemente"
	exit 1
fi

apt-get update
apt-get install live-build
mkdir debian-live ; cd debian-live ; lb init ; lb config
lb config --distribution testing
lb config --archive-areas "main contrib non-free"
lb config --bootappend-live "boot=live config locales=es_AR.UTF-8 keyboard-layouts=es"
echo "task-xfce-desktop iceweasel task-spanish task-spanish-desktop debian-installer-launcher" >> config/package-lists/my.list.chroot
lb build

