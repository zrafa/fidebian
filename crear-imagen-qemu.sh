#!/bin/bash

# Este script es un peligro. Hay que Ser root
# NO tener nada en pwd
# El script no chequea si algo falla. Dale que va..
# 
# Uso : 
#     ./crear-debianvm.sh  nbd0|nbd1..  size(enMegabytes)
#

if ! [ $# -eq 2 ] ; then 
	echo "Uso : ./crear-image-qemu.sh  nbd0|nbd1..  size(enMegabytes)"
	exit 1 
fi

NBD=$1
SIZE=$2

rm debian-testing.img
qemu-img create -f qcow2 debian-testing.img ${SIZE}M

# conectamos el archivo disco a un dispositivo nbd
modprobe nbd max_part=8
RUTA=`pwd`
umount /dev/${NBD}p1
killall qemu-nbd
qemu-nbd --disconnect ${RUTA}/debian-testing.img 
qemu-nbd --connect=/dev/${NBD} ${RUTA}/debian-testing.img 

# creamos la particion sda1 y copiamos el FS debian testing
echo "n
p
1


w
" | fdisk /dev/${NBD}

mkfs.ext4 /dev/${NBD}p1
rm -rf m ; mkdir m
mount /dev/${NBD}p1 m
cd tmp
cp -a . ../m
cd ..
umount m

# desconectamos el archivo disco del dispositivo nbd
umount /dev/${NBD}p1
killall qemu-nbd
qemu-nbd -d /dev/${NBD}
qemu-nbd -d ${RUTA}/debian-testing.img 

# iniciamos qemu para instalar grub automaticamente a sda
qemu -kernel tmp/boot/vmlinuz-*-pae -initrd tmp/boot/initrd.img-*-pae -hda debian-testing.img  -append "root=/dev/sda1" -nographic

