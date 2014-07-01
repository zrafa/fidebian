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
       Ventajas :
	* Casi nunca se rompe el apt-get update; apt-get dist-upgrade, 
	  aun cuando se realice una vez al año.
	* Nunca hay que cambiar de version, Debian Testing es siempre la última
	  versión.
	* Tendremos la posibilidad de contar siempre con la última versión de 
	  los programas, o de poder instalar programas nuevos que aparezcan.
 - Construido utilizando debian-live (live-build : lb build)
 - Sin agregados extraños (utilizar paquetes sólo de los repositorios)
 - Que sea posible utilizarse como :
    * Distribución GNU/Linux Live.
    * Instalador.
    * Distribución GNU/Linux instalada en el equipo internamente.
 - Contar con un repositorio local de Debian testing. ¿Posiblemente "congelado"?
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


Sistema Base
------------

Entorno de escritorio : xfce
Navegador web : chromium (y iceweasel?)
Programas y plugins utilizados por las materias.
Launcher del Instalador de Debian (icono que aperece en el escritorio una vez
iniciado el Live CD, que permite instalar el sistema en la máquina)


Uso
---

Para construir la distribución : make

