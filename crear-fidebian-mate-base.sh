#!/bin/bash

# Este script es un peligro. Hay que Ser root
# NO tener nada en pwd
# El script no chequea si algo falla. Dale que va..
# 
# Uso : 
#     ./crear-fidebian.sh
#

# Requisitos :
# - Que haya espacio disponible
# - Que el usuario sea root

DIR=base

# FUNCTION : crear listado de repositorios
function crear_listado_de_repos(){
	
	echo 'deb http://mirror.fi.uncoma.edu.ar/debian/ testing main contrib non-free
# deb http://ftp.us.debian.org/debian/ testing main contrib non-free
' > ${DIR}/etc/apt/sources.list
chroot ${DIR} apt-get update


}

# Verificamos que haya al menos 10GB libres

LIBRE=`df -B 1G . | tail -1 | awk '{print $4}'`
if [[ $LIBRE -lt 10 ]]; then
        echo "No hay al menos 10GB de espacio Libre"
        exit 1
fi


# Verificamos que el usuario sea root

if [[ "`whoami`" != "root" ]]; then
        echo "Debe ser root lamentablemente"
        exit 1
fi

# Verificamos que exista debootstrap
if ! which debootstrap ; then echo "Falta debootstrap" ; exit 1 ; fi


if [ -d ${DIR}/ ] ; then 
	echo "Error: el directorio ${DIR}/ existe! (`pwd`). 
Se debe borrar o mover antes de ejecutar $0"
	exit 1
fi

mkdir ${DIR}
debootstrap testing ${DIR} http://mirror.fi.uncoma.edu.ar/debian/

# password de root : root
cat ${DIR}/etc/shadow | grep -v "root:" >> ${DIR}/shadow.${DIR}
echo 'root:$6$5KV7doB3$sum2xuCBM9TibuVGAwvZ4rbT.EL1.RG.CmmZrEndf6NESIiTJ1pIrILC356XMzMoLexjKEmPSnYIH96BaeSY2.:15642:0:99999:7:::' >> ${DIR}/shadow.${DIR}
mv ${DIR}/shadow.${DIR} ${DIR}/etc/shadow
chmod 640 ${DIR}/etc/shadow

# hostname
echo "fidebian" > ${DIR}/etc/hostname

# DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" >> ${DIR}/etc/resolv.conf 

# se agrega el mirror local de Debian
crear_listado_de_repos

# instalamos kernel, ssh server y grub
chroot ${DIR} apt-get -y install linux-image-686-pae || chroot ${DIR} apt-get -y install linux-image-amd64
chroot ${DIR} apt-get -y install openssh-server

mount -t proc proc ${DIR}/proc
mount -t sysfs sys ${DIR}/sys
mount --bind /dev ${DIR}/dev
# instalamos el locales y seleccionamos es-AR.utf8
#   locales=es_AR.UTF-8 
chroot ${DIR} apt-get -y install locales
echo "es_AR.UTF-8 UTF-8" > ${DIR}/etc/locale.gen    
chroot ${DIR} /usr/sbin/locale-gen
# chroot ${DIR} dpkg-reconfigure locales


# time zone
echo "America/Argentina/Buenos_Aires" > ${DIR}/etc/timezone    
chroot ${DIR} dpkg-reconfigure -f noninteractive tzdata

# instalamos software de las aulas
chroot ${DIR} apt-get -y install task-desktop task-mate-desktop chromium iceweasel console-setup

# Esto es un workaround : Volvemos a agregar los DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > ${DIR}/etc/resolv.conf 

# falta pulseaudio ?

# instalamos firmware binarios free and non free (para que funcionen principalmente los dispositivos de red)
chroot ${DIR} apt-cache search firmware | egrep "\-firmware|firmware\-" | awk '{print $1}' | 
	grep -v grub | grep -v qemu | 
	while read paquete ; do apt-get -y install $paquete ; done

# instalamos los paquetes en espaniol
chroot ${DIR} apt-get -y install iceweasel-l10n-es-ar libreoffice-l10n-es
# Decirle que queremos :
#   keyboard-layouts=es"

# Esta es una prueba para obtener un sistema en espaniol
# Test: el locale esta configurado, pero no aparece en espaniol el sistema
echo "LANG=es_AR.UTF-8" > ${DIR}/etc/default/locale


# Quitamos los archives de paquetes bajados
chroot ${DIR} apt-get autoclean
chroot ${DIR} apt-get clean


# Desmontamos 
umount ${DIR}/dev
umount ${DIR}/sys
umount ${DIR}/proc

init 6
