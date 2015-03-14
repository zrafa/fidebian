#!/bin/bash
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


function montar_con_aufs () {
	DIR=$1
	mkdir /mnt/${DIR}ro
	mkdir /mnt/${DIR}rw
	mkdir /mnt/${DIR}aufs
	mount --bind /${DIR} /mnt/${DIR}ro
	mount -t tmpfs none /mnt/${DIR}rw
	mount -t aufs -o dirs=/mnt/${DIR}rw:/mnt/${DIR}ro=ro none /mnt/${DIR}aufs
	###       mount --move /mnt/${DIR}aufs /${DIR}
	mount --bind /mnt/${DIR}aufs /${DIR}

}



mount -t tmpfs none /mnt
mount -t tmpfs none /tmp


for i in bin lib sbin usr boot etc home root var ; do 
	montar_con_aufs $i
done
