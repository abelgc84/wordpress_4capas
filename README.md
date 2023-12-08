# wordpress_4capas
Despliegue automático de un CMS wordpress en una infraestructura de cuatro capas con alta disponibilidad.

# Índice.

1. [Introducción.](#introducción)
2. [Infraestructura.](#infraestructura)
    * [VagrantFile.](#vagrantfile)
3. [Scripts de provisionamiento.](scripts_de_provisionamiento) 
    * [Balanceador Web.](#balanceador-web)
    * [Servidor NFS-PHP.](#servidor-nfs-php)
    * [Servidor web 1.](#servidor-web-1)
    * [Servidor web 2.](#servidor-web-2)
    * [Balanceador BBDD.](#balanceador-bbdd)
    * [Servidor de datos 1.](#servidor-de-datos-1)
    * [Servidor de datos 2.](#servidor-de-datos-2)
4. [Screencash](#screencash)

# Introducción.

# Infraestructura.

## VagrantFile.

# Scripts de provisionamiento.

## Balanceador Web.

## Servidor NFS-PHP.

## Servidor web 1.

## Servidor web 2.

## Balanceador BBDD.

## Servidor de datos 1.

## Servidor de datos 2.

# Screencash.

Se trata de desplegar un CMS Wordpress en una infraestructura en alta disponibilidad de 3 capas basada en una pila LEMP con la siguiente estructura:

Capa 1: Expuesta a red pública. Una máquina con balanceador de carga Nginx. (Nombre máquina balanceadorTuNombre).
Capa 2: BackEnd. 
Dos máquinas con un servidor web nginx cada una. (serverweb1TuNombre y serverweb2TuNombre).
Una máquina con un servidor NFS y motor PHP-FPM (serverNFSTuNombre).
Capa 3: Datos. Base de datos MariaDB (serverdatosTuNombre).
Las capas 2 y 3 no estarán expuestas a red pública. Los servidores web utilizarán carpeta compartida por NFS desde el serverNFS y además utilizarán el motor PHP-FPM instalado es una misma máquina.


Habrá que hacer una mínima personalización de wordpress: en el aula virtual hay algún material que hace referencia a esto.

Se entregará:

Enlace a repostorio GitHub con el proyecto, que contedrá.
Documento técnico Readme.md.
Fichero vagranfile.
Ficheros de provisionamiento.
Screencash visualizando el funcionamiento de la aplicación.
Requisitos IMPRESCINDIBLES para la entrega:

Documento técnico. Contendrá:
Índice.
Introducción, explicando que se va a realizar y sobre qué infraestructura, explicando el direccionamiento IP utilizado.
Explicación paso a paso de todas las instalaciones y configuraciones a realizar, incluyendo imágenes y código cuando sea necesario.
Imprescindible: No puede contener faltas de ortografía y se debe cuidar la redacción.
Screencash: un solo vídeo en el que se grabará la pantalla realizando las siguientes acciones, en el mismo orden:
Mostrar estado de las máquinas: vagrant status.
Ping cada máquina a todas las demás.
Sistemas de archivos montados en los servidores web: df -h en cada servidor web.
Acceso a servidor MariaDB desde las máquinas serverweb1 y serverweb2.
Acceso a Wordpress desde la máquina anfitriona (Windows) y el puerto mapeado.
Mostrar el fichero /var/log/nginx/access.log en el balanceador de carga.
Mostrar el fichero /var/log/nginx/access.log en los servidores web.
Para el servidor web serverweb1 y volver a acceder a wordpress desde la máquina anfitriona.
Mostrar el fichero /var/log/nginx/access.log en los servidores web.
