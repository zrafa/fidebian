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


DIR=aula

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

if [ -d ${DIR}/ ] ; then 
	echo "Error: el directorio ${DIR}/ existe! (`pwd`). 
Se debe borrar o mover antes de ejecutar $0"
	exit 1
fi


cp -a base ${DIR}

mount -t proc proc tmp/proc
mount -t sysfs sys tmp/sys
mount --bind /dev tmp/dev

# instalamos software de las aulas
chroot tmp apt-get -y install eclipse build-essential php5 wxmaxima scilab emacs build-essential git-core bootcd

chroot tmp apt-get -y install ghc hugs manpages-dev phpmyadmin swi-prolog vim-gtk squeak-vm fpc gnat 

# Esto es un workaround : Volvemos a agregar los DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > tmp/etc/resolv.conf 

# falta pulseaudio ?

# instalamos software adicional como netbeans desde unstable
echo 'deb http://ftp.us.debian.org/debian/ unstable main contrib non-free
' >> tmp/etc/apt/sources.list
chroot tmp apt-get update
chroot tmp apt-get -y install netbeans
crear_listado_de_repos

# Instalar Paquetes necesarios para cups y escaner
chroot tmp apt-get -y install cups system-config-printer hplip sane libsane-dev sane-utils xsane


# Quitamos los archives de paquetes bajados
chroot tmp apt-get autoclean

# Desmontamos 
umount tmp/dev
umount tmp/sys
umount tmp/proc

