
Servidor PXE SERVER
===================

` ` `
 root@pxe-server:/srv/tftp# dpkg -l | grep ftp
ii  tftpd-hpa                     5.2+20140608-3              i386
    HPA's tftp server




root@pxe-server:/srv/tftp# ls
boot  cdimage_dir  cdimage.iso  display.msg  m  pxelinux.0  pxelinux.cfg
root@pxe-server:/srv/tftp#




root@pxe-server:/srv/tftp# cat display.msg

BOOT OPTIONS
ubuntu-10.10


root@pxe-server:/srv/tftp# ls boot/
initrd  vmlinuz


root@pxe-server:/srv/tftp# cat pxelinux.cfg/default
default debian-testing-pxe
timeout 1
prompt 1
serial 0 9600
display display.msg

label debian-testing-pxe
    kernel boot/vmlinuz

  append initrd=boot/initrd root=/dev/nfs
nfsroot=10.0.15.145:/srv/tftp/cdimage_dir/ init=/sbin/init netboot=nfs
ip=dhcp

` ` `


Archivos de la maquina pxe linux 
================================

` ` `


ultimos archivos modificados
root@pxe-server:/etc/rcS.d# mv
/srv/tftp/cdimage_dir/etc/rcS.d/S01aufs.sh
/srv/tftp/cdimage_dir/etc/rcS.d/S12aufs
root@pxe-server:/etc/rcS.d# vi /srv/tftp/pxelinux.cfg/default
root@pxe-server:/etc/rcS.d# vi  /srv/tftp/cdimage_dir/etc/rcS.d/S12aufs
root@pxe-server:/etc/rcS.d# vi /srv/tftp/cdimage_dir/etc/lightdm/lightdm.conf
root@pxe-server:/etc/rcS.d# vi /srv/tftp/cdimage_dir/etc/network/interfaces
root@pxe-server:/etc/rcS.d# vi /srv/tftp/cdimage_dir/etc/passwd
root@pxe-server:/etc/rcS.d# vi  /srv/tftp/cdimage_dir/etc/rcS.d/S12aufs


En /srv/tftp/cdimage_dir/etc/rcS.d/S12aufs :


#! /bin/sh

echo "Intentamos con aufs"
mount -t tmpfs none /mnt
mkdir /mnt/ro
mkdir /mnt/rw
mkdir /mnt/aufs
mount --bind /var /mnt/ro
mount -t tmpfs none /mnt/rw
mount -t aufs -o dirs=/mnt/rw:/mnt/ro=ro none /mnt/aufs
mount --move /mnt/aufs /var



mkdir /mnt/etcro
mkdir /mnt/etcrw
mkdir /mnt/etcaufs
mount --bind /etc /mnt/etcro
mount -t tmpfs none /mnt/etcrw
mount -t aufs -o dirs=/mnt/etcrw:/mnt/etcro=ro none /mnt/etcaufs
mount --move /mnt/etcaufs /etc


mount -t tmpfs none /tmp

#/bin/sh





En root@pxe-server:/etc/rcS.d# vi /srv/tftp/cdimage_dir/etc/network/interfaces :

# interfaces(5) file used by ifup(8) and ifdown(8)
auto lo
iface lo inet loopback

# auto eth0
# iface eth0 inet dhcp





En lightdm.conf pusimos el usuario alumno 

pam-service=lightdm

autologin-user=alumno
autologin-user-timeout=0

` ` `


