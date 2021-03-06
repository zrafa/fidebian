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

# FUNCTION : crear listado oficial de repositorios
function crear_listado_oficial_de_repos(){
	
	echo '# deb http://10.0.17.4/debian/ testing main contrib non-free
deb http://ftp.us.debian.org/debian/ testing main contrib non-free
' > ${DIR}/etc/apt/sources.list
chroot ${DIR} apt-get update

}



# FUNCTION : crear listado de repositorios
function crear_listado_de_repos(){
	
	echo 'deb http://10.0.17.4/debian/ testing main contrib non-free
# deb http://ftp.us.debian.org/debian/ testing main contrib non-free
' > ${DIR}/etc/apt/sources.list
chroot ${DIR} apt-get update

}


# Verificamos que se elige una version base o del aula
if [ "$1" != "base" ] && [ "$1" != "aula" ] ; then
	echo "Uso : crear-fidebian-live.sh   [ base | aula ]"
	exit 1
fi
DIR=live-${1}-instalador

# Verificamos que exista mksquashfs
if ! which mksquashfs ; then echo "Falta mksquashfs" ; exit 1 ; fi


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


# Verifivamos que no existe el directorio de trabajo
if [ -d ${DIR}/ ] ; then 
	echo "Error: el directorio ${DIR}/ existe! (`pwd`). 
Se debe borrar o mover antes de ejecutar $0"
	exit 1
fi

# Verificamos que exista aula
if [ ! -d ${1} ] ; then 
	echo "Error: el directorio ${1}/ NO existe! (`pwd`). 
El directorio ${1} debe existir antes de ejecutar $0"
	exit 1
fi

cp -a ${1} ${DIR}

# Creamos el usuario invitado
chroot ${DIR} useradd -d /home/invitado -c invitado -m -s /bin/bash -u 1500 -U invitado 
cat ${DIR}/etc/shadow | grep -v "invitado:" >> ${DIR}/shadow.${DIR}
echo 'invitado:$6$O0IGEAzF$EIdnVAEPX06RJiGMBEdm6IrQKvupcd63n1skNsZO8qImOyp/B2lh2zfuuF/2J.J9VzMyVQbCpjBc6JZp8EDPB/:16476:0:99999:7:::' >> ${DIR}/shadow.${DIR}
mv ${DIR}/shadow.${DIR} ${DIR}/etc/shadow
chmod 640 ${DIR}/etc/shadow

# se agrega el mirror oficial de Debian
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

# Agregamos a invitado a sudoers sin clave
echo 'invitado    ALL=NOPASSWD: ALL' >> ${DIR}/etc/sudoers





#Instalamos las dependencias del instalador live-installer de linuxmint  https://github.com/linuxmint/live-installer
chroot ${DIR} apt-get -y install python-gtk2 python-glade2 python-webkit python-parted parted gparted python-qt4 python-opencv python-imaging imagemagick isoquery desktop-file-utils shared-mime-info sysv-rc menu gdisk iso-codes locales adduser


# Instalamos GRUB
chroot ${DIR} apt-get -y install grub2

# Instalamos el live-installer
cp extras/live-installer_2015.02.19_all.deb ${DIR}/tmp/
chroot ${DIR} dpkg -i /tmp/live-installer_2015.02.19_all.deb

# se agrega el mirror oficial de Debian
crear_listado_oficial_de_repos

# Quitamos los archives de paquetes bajados
chroot ${DIR} apt-get autoclean
chroot ${DIR} apt-get clean

# Desmontamos 
umount ${DIR}/dev
umount ${DIR}/sys
umount ${DIR}/proc

# Dejamos una marca de tiempo para identificar la distro 
date +"%s" > ${DIR}/root/build.txt

# Creamos el squashfs para el instalador
rm filesystem.squashfs 
rm ${DIR}/var/spool/bootcd/cdimage.iso 
rm ${DIR}/lib/live/mount/medium/live/filesystem.squashfs 
rm ${DIR}/lib/live/mount/medium/live/borrame
mkdir -p ${DIR}/lib/live/mount/medium/live/
# Este comando debajo era el original 
# mksquashfs ${DIR}/ filesystem.squashfs
# TODO: por favor, modificar el instalador live-installer
#       correctamente, para no tener que crear este archivo
#       Lo creamos para que el instalador lo encuentre simplemente
touch ${DIR}/lib/live/mount/medium/live/borrame
mksquashfs ${DIR}/lib/live/mount/medium/live/ filesystem.squashfs
mv filesystem.squashfs ${DIR}/lib/live/mount/medium/live/

# Agregamos el icono lanzador del instalador para invitado
mkdir ${DIR}/home/invitado/Desktop
mkdir ${DIR}/home/invitado/Escritorio
cp extras/instalador.desktop ${DIR}/home/invitado/Desktop
cp extras/instalador.desktop ${DIR}/home/invitado/Escritorio
chmod a+x ${DIR}/home/invitado/Desktop/instalador.desktop
chmod a+x ${DIR}/home/invitado/Escritorio/instalador.desktop






# autologin con usuario invitado
cat ${DIR}/etc/lightdm/lightdm.conf  | sed -e "s/#autologin-user=/autologin-user=invitado/" -e "s/#autologin-user-timeout=0/autologin-user-timeout=0/" >> ${DIR}/lightdm.conf.bkp ; mv ${DIR}/lightdm.conf.bkp ${DIR}/etc/lightdm/lightdm.conf
echo 'Debian GNU/Linux version Testing 
Facultad de Informatica - Universidad Nacional del Comahue
' > ${DIR}/usr/share/bootcd/default.txt 
chroot ${DIR} bootcdwrite -s
echo "${DIR}/var/spool/bootcd/cdimage.iso es el archivo live DVD Debian creado."

# init 6
exit 0



