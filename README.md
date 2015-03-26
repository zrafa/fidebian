fidebian
========

http://se.fi.uncoma.edu.ar/fidebian

Este repositorio contiene el sistema de creación de la distribución Debian
GNU/Linux para los laboratorios de la Facultad de Informática de la Universidad
Nacional del Comahue.

El sistema operativo Debian elaborado será también el que se utilice
en las estaciones de trabajo de las oficinas, y el oficialmente sugerido
a la planta no docente y docente.

Objetivos :

 - Basado en Debian Testing. 
 - Sin agregados extraños (utilizar paquetes sólo de los repositorios)
 - Que sea posible utilizarse como :
    * Distribución GNU/Linux Live.
    * Instalador.
    * Distribución GNU/Linux instalada en el equipo internamente.


¿Por qué Debian Testing?
------------------------

* Casi nunca se rompe el apt-get update; apt-get dist-upgrade, 
  aun cuando se realice una vez al año.
* Nunca hay que cambiar de version, Debian Testing es de liberación continua
  (rolling relase. En /etc/apt/sources.list debe decir "testing" como version)
* Tendremos la posibilidad de contar siempre con la última versión de 
  los programas, o de poder instalar programas nuevos que aparezcan.


Sistema Base
------------

- Entorno de escritorio : mate (eom, pluma, mate-terminal, atril, engrampa, caja)
	Paquete : task-mate-desktop
- Navegador web : chromium (y iceweasel?)
- Programas y plugins utilizados por las materias.
   Netbeans
   Eclipse
   wxmaxima (adair)
   scilab (adair)
   exelearning (adair)
   php
   apache
   java
   entorno de desarrollo base : build-essential - Informational list of build-essential packages
   openssh-server
   nfs-common


 vim-gnome build-essential wireshark eclipse-jdt 
           netbeans emacs otter bison flex bouml bouml-plugouts-src 
           php5 libapache2-mod-php5 apache2 mysql-client php5-mysql 
           php5-curl php5-gd php5-idn php-pear php5-imagick php5-imap
           php5-mcrypt php5-memcache php5-mhash php5-ming php5-ps php5-pspell
           php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-json
           mysql-query-browser helium hmake hugs

- Launcher del Instalador de Debian (icono que aperece en el escritorio una vez
  iniciado el Live CD, que permite instalar el sistema en la máquina)
- Latexila


Objetivos secundarios
---------------------

Contar con un repositorio local de Debian testing. ¿Posiblemente "congelado"?
¿Y actualizado cada 6 meses o un año?. Con lo lindo que es instalar software
nuevo este objetivo parece desalentador, pero ¿Cómo mantener un repo
"estable" estando en Debian testing? ¿Para evitar que estaciones de trabajo
diferentes tengan versiones diferentes de software?


Nombre
------

Debi ?
FiDebian?
FaiDebian ?
GNUFix?
Colocar sugerencias..


Uso
---

Para construir la distribución : make



Lo que los usuarios utilizan
----------------------------

Laura Cecchi está utilizando Debian testing. Así como algunos pocos docentes
mas.

Algunos detalles :

- Quieren skype para comunicacion. La ultima version de la web de skype
está para descarga en formato Debian. IMPORTANTE: para que funcione el sonido
se necesita pulseaudio server.
- gummi (buggy) o latexila?. Tiene buena aceptación para Latex. Hay que estar seguros que la distro tambien tiene los paquetes para latex en español (acentos, eñes), utf8, figuras, separador de silabas, etc.
- mate-pluma es el viejo editor de texto gnome-text-editor. El nuevo
  editor de gnome es odiado casi por todos, asi que se puede instalar pluma.
- EL complemento de ver el estado de la bateria es de suma importancia
  para los docentes con netbooks/notebooks. Verificar cual es el que funciona
  bien (Laura Cecchi lo tiene en funcionamiento).
- La fecha y hora debe mostrar tambien el calendario.
- No es sencillo en xfce cambiar la fecha y hora. Ver que hacer.


Software utilizado por las materias
===================================

- Programas de desarrollo de software esenciales (paquete build-essential que trae libc6-dev | libc-dev, gcc, g++, make, dpkg-dev)
- Netbeans
- Java
- Eclipse
- php
- Plugines de c++, php y java para eclipse y netbeans


Para construir un live cd desde una instalacion de disco
========================================================

Utilizaremos el paquete bootcd
Configuramos una PC origen con Debian Testing y todo el software utilizado
en las aulas. Luego con bootcd creamos la imagen a ser arrancada
via pxe boot por las PCs de las aulas.

bootcd
Description-en: run your system from cd without need for disks
 Build an image of your running Debian System with the command bootcdwrite.
 You can also build a bootcd ISO image via NFS on a remote System.
 When you run your system from CD you do not need any disks. All
 changes will be done in ram.

Instalar y ejecutar bootcdwrite

Autologin para el Autogestion
=============================

Habilitando el autologin

Edite /etc/lightdm/lightdm.conf y cámbielo por algo como esto:
[SeatDefaults] 
autologin-user=su_usuario 
autologin-user-timeout=0 
pam-service=lightdm-autologin 


Construir el paquete live-installer de linuxmint
================================================

cd live-installer 
dpkg-buildpackage -us -uc
rm tmp/lib/live/mount/medium/live/filesystem.squashfs
mksquashfs tmp/ filesystem.squashfs
mv filesystem.squashfs tmp/lib/live/mount/medium/live/filesystem.squashfs
cdroot tmp bootcdwrite -s

