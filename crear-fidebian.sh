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

# Creamos el usuario invitado
chroot tmp useradd -d /home/invitado -c invitado -m -s /bin/bash -u 1500 -U invitado 
cat tmp/etc/shadow | grep -v "invitado:" >> tmp/shadow.tmp
echo 'invitado:$6$O0IGEAzF$EIdnVAEPX06RJiGMBEdm6IrQKvupcd63n1skNsZO8qImOyp/B2lh2zfuuF/2J.J9VzMyVQbCpjBc6JZp8EDPB/:16476:0:99999:7:::' >> tmp/shadow.tmp
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
chroot tmp apt-get -y install task-desktop task-mate-desktop eclipse chromium iceweasel build-essential php5 wxmaxima scilab emacs build-essential git-core bootcd

# Esto es un workaround : Volvemos a agregar los DNS server from google
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > tmp/etc/resolv.conf 

# falta pulseaudio ?
# instalamos firmware binarios non free (para que funcionen principalmente los dispositivos de red)
# instalamos software adicional como netbeans desde unstable
echo 'deb http://ftp.us.debian.org/debian/ unstable main contrib non-free
' >> tmp/etc/apt/sources.list
chroot tmp apt-get update
chroot tmp apt-get -y install netbeans
crear_listado_de_repos

# instalamos los paquetes en espaniol
chroot tmp apt-get -y install iceweasel-l10n-es-ar libreoffice-l10n-es
# Decirle que queremos :
#   keyboard-layouts=es"

#Instalamos las dependencias del instalador live-installer de linuxmint  https://github.com/linuxmint/live-installer
chroot tmp apt-get -y install python-gtk2 python-glade2 python-webkit python-parted parted gparted python-qt4 python-opencv python-imaging imagemagick isoquery desktop-file-utils shared-mime-info sysv-rc menu gdisk iso-codes locales adduser

# Instalar bootcd y ejecutarlo (bootcdwrite) para generar el DVD booteable

# Esta es una prueba para obtener un sistema en espaniol
# Test: el locale esta configurado, pero no aparece en espaniol el sistema
echo "LANG=es_AR.UTF-8" > tmp/etc/default/locale

# Tuneo : no queremos nada acá, pero podemos dejar alguna marca nuestra al menos
cp extras/lines-wallpaper_1920x1080.svg tmp/usr/share/images/desktop-base/
cp extras/login-background.svg tmp/usr/share/images/desktop-base/

# Quitamos los archives de paquetes bajados
chroot tmp apt-get autoclean

umount tmp/dev
umount tmp/sys
umount tmp/proc

echo -n "

==========  Elija una opcion  ===========================
1 : Crear iso
2 : Crear imagen para virt-manager
3 : Salir y obtener unicamente el directorio image

Su eleccion : "

read respuesta
while ! (echo $respuesta | egrep "1|2|3") ; do
	echo -n "
Su eleccion : "
	read respuesta
done


if [ $respuesta = "3" ] ; then 
	echo "Directorio tmp/ (`pwd`/tmp/) contiene el sistema Debian creado."
	exit 0
elif [ $respuesta = "1" ] ; then 
	# autologin con usuario invitado
	cat tmp/etc/lightdm/lightdm.conf  | sed -e "s/#autologin-user=/autologin-user=invitado/" -e "s/#autologin-user-timeout=0/autologin-user-timeout=0/" >> tmp/lightdm.conf.bkp ; mv tmp/lightdm.conf.bkp tmp/etc/lightdm/lightdm.conf
	echo 'Debian GNU/Linux version Testing 
Facultad de Informatica - Universidad Nacional del Comahue
' > tmp/usr/share/bootcd/default.txt 
	chroot tmp bootcdwrite -s
	echo "tmp/var/spool/bootcd/cdimage.iso es el archivo live DVD Debian creado."
	exit 0
fi


for i in qemu-img qemu-nbd qemu ; do
	if ! which $i ; then echo "Falta $i" ; exit 1 ; fi
done
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

