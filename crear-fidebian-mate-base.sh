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


# FUNCTION : crear listado de repositorios
function crear_listado_de_repos(){
	
	echo 'deb http://mirror.fi.uncoma.edu.ar/debian/ testing main contrib non-free
# deb http://ftp.us.debian.org/debian/ testing main contrib non-free
' > tmp/etc/apt/sources.list
chroot tmp apt-get update


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


if [ -d tmp/ ] ; then 
	echo "Error: el directorio tmp/ existe! (`pwd`). 
Se debe borrar o mover antes de ejecutar $0"
	exit 1
fi

mkdir tmp
debootstrap testing tmp http://mirror.fi.uncoma.edu.ar/debian/

# password de root : root
cat tmp/etc/shadow | grep -v "root:" >> tmp/shadow.tmp
echo 'root:$6$5KV7doB3$sum2xuCBM9TibuVGAwvZ4rbT.EL1.RG.CmmZrEndf6NESIiTJ1pIrILC356XMzMoLexjKEmPSnYIH96BaeSY2.:15642:0:99999:7:::' >> tmp/shadow.tmp
mv tmp/shadow.tmp tmp/etc/shadow
chmod 640 tmp/etc/shadow

# hostname
echo "fidebian" > tmp/etc/hostname

# DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" >> tmp/etc/resolv.conf 

# se agrega el mirror local de Debian
crear_listado_de_repos

# instalamos kernel, ssh server y grub
chroot tmp apt-get -y install linux-image-686-pae
chroot tmp apt-get -y install openssh-server

mount -t proc proc tmp/proc
mount -t sysfs sys tmp/sys
mount --bind /dev tmp/dev
# instalamos el locales y seleccionamos es-AR.utf8
#   locales=es_AR.UTF-8 
chroot tmp apt-get -y install locales
echo "es_AR.UTF-8 UTF-8" > tmp/etc/locale.gen    
chroot tmp /usr/sbin/locale-gen
# chroot tmp dpkg-reconfigure locales


# time zone
echo "America/Argentina/Buenos_Aires" > tmp/etc/timezone    
chroot tmp dpkg-reconfigure -f noninteractive tzdata

# instalamos software de las aulas
chroot tmp apt-get -y install task-desktop task-mate-desktop chromium iceweasel

# Esto es un workaround : Volvemos a agregar los DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > tmp/etc/resolv.conf 

# falta pulseaudio ?

# instalamos firmware binarios free and non free (para que funcionen principalmente los dispositivos de red)
chroot tmp apt-get -y install $(apt-cache search firmware | egrep "\-firmware|firmware\-" | awk '{print $1}' | while read line ; do echo -n $line" " ; done)

# instalamos los paquetes en espaniol
chroot tmp apt-get -y install iceweasel-l10n-es-ar libreoffice-l10n-es
# Decirle que queremos :
#   keyboard-layouts=es"

# Esta es una prueba para obtener un sistema en espaniol
# Test: el locale esta configurado, pero no aparece en espaniol el sistema
echo "LANG=es_AR.UTF-8" > tmp/etc/default/locale


# Quitamos los archives de paquetes bajados
chroot tmp apt-get autoclean


# Desmontamos 
umount tmp/dev
umount tmp/sys
umount tmp/proc

