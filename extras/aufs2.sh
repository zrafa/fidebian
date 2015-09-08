#!/bin/sh
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.



#echo "Intentamos con aufs"

montar_con_aufs () {
	DIR=$1
	mkdir -p /mnt/${DIR}ro
	mkdir -p /mnt/${DIR}rw
	mkdir -p /mnt/${DIR}aufs
	mount -o bind /root/${DIR} /mnt/${DIR}ro
	mount -t tmpfs -o noatime,nodiratime,mode=755 none /mnt/${DIR}rw
	### unionfs-fuse /mnt/${DIR}rw=RW:/mnt/${DIR}ro=RO /mnt/${DIR}aufs
	mount -t aufs -o dirs=/mnt/${DIR}rw=rw:/mnt/${DIR}ro=ro none /mnt/${DIR}aufs
	###       mount --move /mnt/${DIR}aufs /${DIR}
	mount -o bind /mnt/${DIR}aufs /root/${DIR}

}

insmod /root/lib/modules/3.16.0-4-amd64/kernel/fs/aufs/aufs.ko 


mount -t tmpfs -o noatime,nodiratime,mode=755 none /root/tmp

# PRIMERO etc !!
# for i in var etc lib sbin usr boot home root bin ; do 
for i in var etc lib sbin usr boot home root bin media ; do 
# for i in var etc home root ; do 
	echo MOUNT $i
	montar_con_aufs $i
done

