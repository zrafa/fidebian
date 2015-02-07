#!/bin/bash

# Este script es un peligro. Hay que Ser root
# NO tener nada en pwd
# El script no chequea si algo falla. Dale que va..
# 
# Uso : 
#     ./crear-debianvm.sh  nbd0|nbd1..  size(enMegabytes)
#

# if ! [ $# -eq 2 ] ; then 
# 	echo "Uso : ./crear-debianvm.sh  nbd0|nbd1..  size(enMegabytes)"
# 	exit 1 
# fi

# NBD=$1
# SIZE=$2

for i in debootstrap qemu-img qemu-nbd qemu ; do
	if ! which $i ; then echo "Falta $i" ; exit 1 ; fi
done

if [ -d tmp/ ] ; then 
	echo "Error: el directorio tmp/ existe! (`pwd`). 
Se debe borrar o mover antes de ejecutar $0"
	exit 1
fi
mkdir tmp
debootstrap testing tmp 

# password de root : root
cat tmp/etc/shadow | grep -v "root:" >> tmp/shadow.tmp
echo 'root:$6$5KV7doB3$sum2xuCBM9TibuVGAwvZ4rbT.EL1.RG.CmmZrEndf6NESIiTJ1pIrILC356XMzMoLexjKEmPSnYIH96BaeSY2.:15642:0:99999:7:::' >> tmp/shadow.tmp
mv tmp/shadow.tmp tmp/etc/shadow
chmod 640 tmp/etc/shadow


# hostname
echo "debianvm" > tmp/etc/hostname

# DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" >> tmp/etc/resolv.conf 

# se agrega el mirror local de Debian
echo 'deb http://mirror.fi.uncoma.edu.ar/debian/ testing main contrib non-free
# deb http://ftp.us.debian.org/debian/ testing main contrib non-free
' > tmp/etc/apt/sources.list

# instalamos kernel, ssh server y grub
chroot tmp apt-get update
chroot tmp apt-get -y install linux-image-686-pae
chroot tmp apt-get -y install openssh-server

mount --bind /dev/ tmp/dev/
mount --bind /sys tmp/sys
mount --bind /proc tmp/proc
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
chroot tmp apt-get -y install task-desktop task-mate-desktop eclipse chromium iceweasel build-essential php5 wxmaxima scilab emacs build-essential git-core

# falta pulseaudio ?
# instalamos firmware binarios non free (para que funcionen principalmente los dispositivos de red)
# instalamos software adicional como netbeans desde unstable

# instalamos los paquetes en espaniol
chroot tmp apt-get install iceweasel-l10n-es-ar libreoffice-l10n-es
# Decirle que queremos :
#   keyboard-layouts=es"

# Instalar bootcd y ejecutarlo (bootcdwrite) para generar el DVD booteable


# Tuneo : no queremos nada acá, pero podemos dejar alguna marca nuestra al menos
cp extras/lines-wallpaper_1920x1080.svg tmp/usr/share/images/desktop-base/


echo -n "

==========  Elija una opcion  ===========================
1 : Crear iso
2 : Crear imagen para virt-manager
3 : Solamente el directorio image

Su eleccion : "

read respuesta
while ! (echo $respuesta | egrep "1|2|3") ; do
	echo -n "
Su eleccion : "
	read respuesta
done


if [ $respuesta = "3" ] ; then 
	umount tmp/dev
	umount tmp/sys
	umount tmp/proc
	exit 0
elif [ $respuesta = "1" ] ; then 
	chroot tmp apt-get -y install bootcd
	echo 'Debian GNU/Linux version Testing 
Facultad de Informatica - Universidad Nacional del Comahue' > tmp/usr/share/bootcd/default.txt 
	chroot tmp bootcdwrite
	umount tmp/dev
	umount tmp/sys
	umount tmp/proc
	exit 0
fi


# trick para instalar el grub en el primer boot de la maquina virtual
# TODO ATENTOS ! : Unicamente valido si creamos una imagen para virtmanager. 
# Si es para CD-DVD NO hacer ESTO!
chroot tmp apt-get -y install grub2
cp tmp/etc/rc.local tmp/etc/rc.local.bkp
echo '#!/bin/bash

grub-install /dev/sda
update-grub
update-grub2
mv /etc/rc.local.bkp /etc/rc.local
apt-get clean
apt-get autoremove
sync
poweroff
' > tmp/etc/rc.local


# ./crear-imagen-qemu.sh $NBD $SIZE en Megabytes
./crear-imagen-qemu.sh nbd0 10000
