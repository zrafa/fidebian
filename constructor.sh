#!/bin/bash

# Verificar si está instalado debootstrap, live-build, etc


apt-get update
apt-get install live-build
mkdir tutorial1 ; cd tutorial1 ; lb init ; lb config
lb config --distribution testing
lb config --archive-areas "main contrib non-free"
lb config --bootappend-live "boot=live config locales=es_AR.UTF-8 keyboard-layouts=es"
echo "task-xfce-desktop iceweasel task-spanish task-spanish-desktop debian-installer-launcher" >> config/package-lists/my.list.chroot

