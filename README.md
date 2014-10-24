fidebian
========

Este repositorio contiene el sistema de creación de la distribución Debian
GNU/Linux para los laboratorios de la Facultad de Informática de la Universidad
Nacional del Comahue.

El sistema operativo Debian elaborado será también el que se utilice
en las estaciones de trabajo de las oficinas, y el oficialmente sugerido
a la planta no docente y docente.

Objetivos :

 - Basado en Debian Testing. 
 - Construido utilizando debian-live (live-build : lb build)
 - Sin agregados extraños (utilizar paquetes sólo de los repositorios)
 - Que sea posible utilizarse como :
    * Distribución GNU/Linux Live.
    * Instalador.
    * Distribución GNU/Linux instalada en el equipo internamente.


¿Por qué Debian Testing?
------------------------

* Casi nunca se rompe el apt-get update; apt-get dist-upgrade, 
  aun cuando se realice una vez al año.
* Nunca hay que cambiar de version, Debian Testing es siempre la última
  versión (rolling. En /etc/apt/sources.list debe decir "testing" como version)
* Tendremos la posibilidad de contar siempre con la última versión de 
  los programas, o de poder instalar programas nuevos que aparezcan.


Sistema Base
------------

- Entorno de escritorio : xfce o mate?
- Navegador web : chromium (y iceweasel?)
- Programas y plugins utilizados por las materias.
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
