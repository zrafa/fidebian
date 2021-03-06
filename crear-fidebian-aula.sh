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


# Verificamos que exista base
if [ ! -d base ] ; then 
	echo "Error: el directorio base/ NO existe! (`pwd`). 
Debe crear base antes de ejecutar $0"
	exit 1
fi
cp -a base ${DIR}

mount -t proc proc ${DIR}/proc
mount -t sysfs sys ${DIR}/sys
mount --bind /dev ${DIR}/dev

# instalamos software de las aulas
chroot ${DIR} apt-get -y install eclipse build-essential php5 wxmaxima emacs build-essential git-core 
# scilab

# instalamos bootcd
chroot ${DIR} apt-get -y install bootcd
# Quitamos de la busqueda de lectoras a los discos rigidos, y auto va al final
grep -v CDDEV ${DIR}/etc/bootcd/bootcdwrite.conf > ${DIR}/etc/bootcd/bootcdwrite.conf.temporal
echo 'CDDEV="/dev/sr0 /dev/sr1 auto"' >> ${DIR}/etc/bootcd/bootcdwrite.conf.temporal
mv ${DIR}/etc/bootcd/bootcdwrite.conf.temporal ${DIR}/etc/bootcd/bootcdwrite.conf


chroot ${DIR} apt-get -y install hugs manpages-dev phpmyadmin swi-prolog vim-gtk squeak-vm fpc
# gnat ghc wireshark

# Instalar Paquetes necesarios para cups y escaner
# chroot ${DIR} apt-get -y install cups system-config-printer hplip sane libsane-dev sane-utils xsane
# cups system-config-printer hplip sane libsane-dev sane-utils xsane

# Paquetes solicitados en el FORO 
# chroot ${DIR} apt-get -y install lyx latexila dia texlive-lang-spanish imagemagick gnome-orca
# lyx latexila dia texlive-lang-spanish imagemagick orca

# Colocamos la instalacion de las sugerencias en la distro
cp extras/sugerencias.sh ${DIR}/usr/local/bin

# Esto es un workaround : Volvemos a agregar los DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > ${DIR}/etc/resolv.conf 

# falta pulseaudio ?

# instalamos software adicional como netbeans desde unstable
echo 'deb http://ftp.us.debian.org/debian/ unstable main contrib non-free
 ' >> ${DIR}/etc/apt/sources.list
chroot ${DIR} apt-get update
chroot ${DIR} apt-get -y install netbeans

# Desinstalamos el netbeans original de Debian
crear_listado_de_repos
chroot ${DIR} apt-get -y purge netbeans

if ! [[ -a netbeans-8.0.2-linux.sh ]] ; then 
	echo "El archivo netbeans-8.0.2-linux.sh NO EXISTE"
	exit 1
fi

cp netbeans-8.0.2-linux.sh ${DIR}/tmp/
chroot ${DIR} sh /tmp/netbeans-8.0.2-linux.sh --silent


# Quitamos los archives de paquetes bajados
chroot ${DIR} apt-get autoclean
chroot ${DIR} apt-get clean

# Desmontamos 
umount ${DIR}/dev
umount ${DIR}/sys
umount ${DIR}/proc

init 6

