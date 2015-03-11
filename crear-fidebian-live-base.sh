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

DIR=live-base

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

# Verificamos que exista base
if [ ! -d base ] ; then 
	echo "Error: el directorio base/ NO existe! (`pwd`). 
El directorio base debe existir antes de ejecutar $0"
	exit 1
fi

cp -a base ${DIR}

# Creamos el usuario invitado
chroot ${DIR} useradd -d /home/invitado -c invitado -m -s /bin/bash -u 1500 -U invitado 
cat ${DIR}/etc/shadow | grep -v "invitado:" >> ${DIR}/shadow.${DIR}
echo 'invitado:$6$O0IGEAzF$EIdnVAEPX06RJiGMBEdm6IrQKvupcd63n1skNsZO8qImOyp/B2lh2zfuuF/2J.J9VzMyVQbCpjBc6JZp8EDPB/:16476:0:99999:7:::' >> ${DIR}/shadow.${DIR}
mv ${DIR}/shadow.${DIR} ${DIR}/etc/shadow
chmod 640 ${DIR}/etc/shadow

# se agrega el mirror local de Debian
crear_listado_de_repos

mount -t proc proc ${DIR}/proc
mount -t sysfs sys ${DIR}/sys
mount --bind /dev ${DIR}/dev

# Esto es un workaround : Volvemos a agregar los DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > ${DIR}/etc/resolv.conf 

# falta pulseaudio ?

# Instalar bootcd y ejecutarlo (bootcdwrite) para generar el DVD booteable
chroot ${DIR} apt-get -y install bootcd

# Tuneo : no queremos nada acá, pero podemos dejar alguna marca nuestra al menos
cp extras/lines-wallpaper_1920x1080.svg ${DIR}/usr/share/images/desktop-base/
cp extras/login-background.svg ${DIR}/usr/share/images/desktop-base/

# TODO: Peligrosisimo. Este workaraound es para poder desbloquear el screensaver :(
chroot ${DIR} chmod u+s /sbin/unix_chkpwd

# Quitamos los archives de paquetes bajados
chroot ${DIR} apt-get autoclean
chroot ${DIR} apt-get clean

# Agregamos a invitado a sudoers sin clave
echo 'invitado    ALL=NOPASSWD: ALL' >> ${DIR}/etc/sudoers

# Desmontamos 
umount ${DIR}/dev
umount ${DIR}/sys
umount ${DIR}/proc

# autologin con usuario invitado
cat ${DIR}/etc/lightdm/lightdm.conf  | sed -e "s/#autologin-user=/autologin-user=invitado/" -e "s/#autologin-user-timeout=0/autologin-user-timeout=0/" >> ${DIR}/lightdm.conf.bkp ; mv ${DIR}/lightdm.conf.bkp ${DIR}/etc/lightdm/lightdm.conf
echo 'Debian GNU/Linux version Testing 
Facultad de Informatica - Universidad Nacional del Comahue
' > ${DIR}/usr/share/bootcd/default.txt 
chroot ${DIR} bootcdwrite -s
echo "${DIR}/var/spool/bootcd/cdimage.iso es el archivo live DVD Debian creado."
exit 0



