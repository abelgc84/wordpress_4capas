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

En esta práctica se realiza el despliegue automático de un CMS wordpress sobre una infraestructura con cuatro capas. 

En una primera capa tendremos un balanceador de carga que distribuirá las solicitudes entre los servidores web. 
En la segunda capa tendremos los servidores de BackEnd, dos servidores web y un servidor nfs y php. 
En la tercera capa tendremmos un balanceador de carga que distribuirá las solicitudes entre los servidores de bases de datos.
En la cuarta capa tendremos un clúster de base de datos compuesto por dos servidores.

Todas las máquinas tendrán restringida la conexión a su propia red. A excepción del balanceador de carga de la capa 1 que tendrá acceso a Internet. 

# Infraestructura.

De manera esquemática nuestra infrestructura será así:
![esquemap3](https://github.com/abelgc84/wordpress_4capas/assets/146434908/db11dc7e-e3f9-4913-9db6-4c827f65242b)

El direccionamiento IP elegido para las máquinas es el siguiente:
* Balanceador Web:
   * NIC 1: NAT de Virtualbox.
   * NIC 2: 10.0.10.10
* Servidor NFS-PHP:
   * NIC 1: 172.16.0.100
* Servidor web 1:
   * NIC 1: 10.0.10.101
   * NIC 2: 172.16.0.101
* Servidor web 2:
   * NIC 1: 10.0.10.102
   * NIC 2: 172.16.0.102
* Balanceador BBDD:
   * NIC 1: 172.16.0.200
   * NIC 2: 192.168.20.200
* Servidor de datos 1:
   * NIC 1: 192.168.20.201
* Servidor de datos 2:
   * NIC 1: 192.168.20.202
 
Toda la infraestructura que vamos a desplegar se puede observar con total claridad en la configuración del VagrantFile.

## VagrantFile.

```
Vagrant.configure("2") do |config|

  config.vm.box = "debian/buster64"

  #######################
  ###   Balanceador   ###
  #######################

  config.vm.define "balanceadorAbelGC" do |bal|
    bal.vm.hostname = "balanceadorAbelGC"
    # Red aislada
    bal.vm.network "private_network", ip: "10.0.10.10",
      virtualbox_intnet: "red10"
    # Nuestro puerto de entrada
    bal.vm.network "forwarded_port", guest: 80, host:9090
    # Script de provisionamiento para que se ejecute siempre
    bal.vm.provision "shell", path: "balanceadorAbelGC.sh",
      run: "always"
    # Para solucionar problemas con los DNS:
    bal.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###    ServerNFS    ###
  #######################

  config.vm.define "serverNFSAbelGC" do |nfs|
    nfs.vm.hostname = "serverNFSAbelGC"
    nfs.vm.network "private_network", ip: "172.16.0.100",
      virtualbox_intnet: "red172"
    nfs.vm.provision "shell", path: "serverNFSAbelGC.sh",
      run: "always"
    nfs.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###   ServerWeb1    ###
  #######################

  config.vm.define "serverweb1AbelGC" do |sw1|
    sw1.vm.hostname = "serverweb1AbelGC"
    sw1.vm.network "private_network", ip: "10.0.10.101",
      virtualbox_intnet: "red10"
    sw1.vm.network "private_network", ip: "172.16.0.101",
      virtualbox_intnet: "red172"
    sw1.vm.provision "shell", path: "serverweb1AbelGC.sh",
      run: "always"
    sw1.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###   ServerWeb2    ###
  #######################

  config.vm.define "serverweb2AbelGC" do |sw2|
    sw2.vm.hostname = "serverweb2AbelGC"
    sw2.vm.network "private_network", ip: "10.0.10.102",
      virtualbox_intnet: "red10"
    sw2.vm.network "private_network", ip: "172.16.0.102",
      virtualbox_intnet: "red172"
    sw2.vm.provision "shell", path: "serverweb2AbelGC.sh",
      run: "always"
    sw2.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###   ProxyBBDD     ###
  #######################

  config.vm.define "proxyBBDDAbelGC" do |pbd|
    pbd.vm.hostname = "proxyBBDDAbelGC"
    pbd.vm.network "private_network", ip: "172.16.0.200",
      virtualbox_intnet: "red172"
    pbd.vm.network "private_network", ip: "192.168.20.200",
      virtualbox_intnet: "red192"
    pbd.vm.provision "shell", path: "proxyBBDDAbelGC.sh",
      run: "always"
    pbd.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###  Serverdatos1   ###
  #######################

  config.vm.define "serverdatos1AbelGC" do |sd1|
    sd1.vm.hostname = "serverdatos1AbelGC"
    sd1.vm.network "private_network", ip: "192.168.20.201",
      virtualbox_intnet: "red192"
    sd1.vm.provision "shell", path: "serverdatos1AbelGC.sh",
      run: "always"
    sd1.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

  #######################
  ###  Serverdatos2   ###
  #######################

  config.vm.define "serverdatos2AbelGC" do |sd2|
    sd2.vm.hostname = "serverdatos2AbelGC"
    sd2.vm.network "private_network", ip: "192.168.20.202",
      virtualbox_intnet: "red192"
    sd2.vm.provision "shell", path: "serverdatos2AbelGC.sh",
      run: "always"
    sd2.vm.provider "virtualbox" do |vb|
      vb.customize ['modifyvm', :id, '--natdnshostresolver1', 'on']
    end
  end

end
```

# Scripts de provisionamiento.

Todo el proceso se realiza de manera automática mediante los scripts de provisionamiento. En ellos se va explicando cada uno de los pasos que se dan para ir realizando el despligue. Una vez el despligue ha finalizado tan solo quedará entrar en wordpress a través del navegador para finalizar su instalación.

## Balanceador Web.

```
#! /bin/bash
sudo apt update

# Instalación de nginx
echo "=========================================="
echo "Instalando nginx"
echo "=========================================="
# Pequeños sleep para que de tiempo a visualizar por donde va el despligue
sleep 1
sudo apt install -y nginx

# Configuración del Balanceador
echo "=========================================="
echo "Configurando el balanceador de carga."
echo "=========================================="
sleep 1

# Creación de la configuración
configuracion="
upstream servidoresweb {
    server 10.0.10.101;
    server 10.0.10.102;
}
	
server {
    listen      80;
    server_name balanceador;

    location / {
	    proxy_redirect      off;
	    proxy_set_header    X-Real-IP \$remote_addr;
	    proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    Host \$http_host;
        proxy_pass          http://servidoresweb;
	}
}"

# Borrado del archivo default de site-enabled
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# Creación del archivo de configuración del balanceador
if [ ! -f /etc/nginx/conf.d/balanceo.conf ]; then
    sudo touch /etc/nginx/conf.d/balanceo.conf

    # Edición del archivo de configuración para el balanceador
    echo "$configuracion">/etc/nginx/conf.d/balanceo.conf

    # Reinicio del servicio
    sudo systemctl restart nginx

fi
```

## Servidor NFS-PHP.

```
#! /bin/bash
sudo apt update

# Instalación de nfs-kernel-server
echo "=========================================="
echo "Instalando el servidor NFS."
echo "=========================================="
sleep 1
sudo apt install -y nfs-kernel-server

# Creación del directorio compartido
if [ ! -d /var/nfs/cms ]; then
    echo "=========================================="
    echo "Creando el directorio compartido."
    echo "=========================================="
    sleep 1
    sudo mkdir -p /var/nfs/cms
    sudo chown -R nobody:nogroup /var/nfs/cms
    sudo chmod -R 755 /var/nfs/cms
    sudo echo "/var/nfs/cms     172.16.0.101(rw,sync,no_subtree_check) 172.16.0.102(rw,sync,no_subtree_check)">>/etc/exports
    sudo systemctl restart nfs-kernel-server
fi

# Instalación de php
echo "=========================================="
echo "Instalando php."
echo "=========================================="
sleep 1
sudo apt install -y php-fpm
sudo apt install -y php-mysql

# Configuración de php-fmp e instalación de wordpress
if [ ! -f $HOME/.flag ]; then
    # Creo la bandera para evitar que se vuelva a ejecutar la configuración.
    sudo touch $HOME/.flag
    sudo chmod +t $HOME/.flag

    # Editar el listen de fmp
    echo "=========================================="
    echo "Configurando la diretiva listen."
    echo "=========================================="
    sleep 1
    sudo sed -i 's|listen = /run/php/php7.3-fpm.sock|listen = 172.16.0.100:9000|' /etc/php/7.3/fpm/pool.d/www.conf

    # Instalación de wordpress
    echo "=========================================="
    echo "Instalando wordpress."
    echo "=========================================="
    sleep 1

        # Descargar y descomprimir 
    sudo wget https://wordpress.org/latest.tar.gz
    sudo tar -xzvf latest.tar.gz
    sudo mv wordpress/* /var/nfs/cms

        # Editar config.php
    sudo cp /var/nfs/cms/wp-config-sample.php /var/nfs/cms/wp-config.php
    sudo sed -i "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', 'wp_db' );/" /var/nfs/cms/wp-config.php
    sudo sed -i "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', 'wp_usuario' );/" /var/nfs/cms/wp-config.php
    sudo sed -i "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', 'wp1234' );/" /var/nfs/cms/wp-config.php
    sudo sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '172.16.0.200' );/" /var/nfs/cms/wp-config.php

        # Transferir propiedad
    sudo chown -R www-data:www-data /var/nfs/cms
    sudo chmod -R 755 /var/nfs/cms

    # Reinicio del servicio
    sudo systemctl restart php7.3-fpm.service

fi

# Denegar el acceso a internet
sudo ip route del default
```

## Servidor web 1.

```
#! /bin/bash
sudo apt update

# Instalación de nginx y módulos de php
echo "=========================================="
echo "Instalando nginx y módulos de php."
echo "=========================================="
sleep 1
sudo apt install -y nginx
sudo apt install -y php-fpm
sudo apt install -y php-mysql

# Instalación de nfs-common
echo "=========================================="
echo "Instalando el cliente NFS."
echo "=========================================="
sleep 1
sudo apt install -y nfs-common

# Creación de punto de montaje
echo "=========================================="
echo "Creando punto de montaje."
echo "=========================================="
sleep 1
if [ ! -d /var/nfs/cms ]; then
    sudo mkdir -p /var/nfs/cms
fi
sudo mount 172.16.0.100:/var/nfs/cms /var/nfs/cms

# Configuración de nginx
echo "=========================================="
echo "Configurando nginx."
echo "=========================================="
sleep 1

# Creación de la configuración
wordpress="
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/nfs/cms;

        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                try_files \$uri \$uri/ =404;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass 172.16.0.100:9000;
        }
        location ~ /\.ht {
                deny all;
        }
}"

if [ -f /etc/nginx/sites-enabled/default ]; then
    # Eliminación del site predeterminado y creación del site de wordpress
    sudo rm /etc/nginx/sites-enabled/default
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/wordpress
    
    # Configuración y activación del site
    echo "$wordpress">/etc/nginx/sites-available/wordpress
    sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/

    # Reinicio del servicio
    sudo systemctl restart nginx
fi

# Denegar el acceso a internet
sudo ip route del default
```

## Servidor web 2.

```
#! /bin/bash
sudo apt update

# Instalación de nginx y módulos de php
echo "=========================================="
echo "Instalando nginx y módulos de php."
echo "=========================================="
sleep 1
sudo apt install -y nginx
sudo apt install -y php-fpm
sudo apt install -y php-mysql

# Instalación de nfs-common
echo "=========================================="
echo "Instalando el cliente NFS."
echo "=========================================="
sleep 1
sudo apt install -y nfs-common

# Creación de punto de montaje
echo "=========================================="
echo "Creando punto de montaje."
echo "=========================================="
sleep 1
if [ ! -d /var/nfs/cms ]; then
    sudo mkdir -p /var/nfs/cms
fi
sudo mount 172.16.0.100:/var/nfs/cms /var/nfs/cms

# Configuración de nginx
echo "=========================================="
echo "Configurando nginx."
echo "=========================================="
sleep 1

# Creación de la configuración
wordpress="
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/nfs/cms;

        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                try_files \$uri \$uri/ =404;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass 172.16.0.100:9000;
        }
        location ~ /\.ht {
                deny all;
        }
}"

if [ -f /etc/nginx/sites-enabled/default ]; then
    # Eliminación del site predeterminado y creación del site de wordpress
    sudo rm /etc/nginx/sites-enabled/default
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/wordpress
    
    # Configuración y activación del site
    echo "$wordpress">/etc/nginx/sites-available/wordpress
    sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/

    # Reinicio del servicio
    sudo systemctl restart nginx
fi

# Denegar el acceso a internet
sudo ip route del default
```

## Balanceador BBDD.

```
#! /bin/bash
sudo apt update

# Instalación de nginx
echo "=========================================="
echo "Instalando nginx"
echo "=========================================="
sleep 1
sudo apt install -y nginx

# Configuración del Balanceador
echo "=========================================="
echo "Configurando el balanceador de carga."
echo "=========================================="
sleep 1

# Creación de la configuración
configuracion="
stream {
    upstream servidoresdb {
        server 192.168.20.201:3306;
        server 192.168.20.202:3306;
    }

    server {
        listen 3306;
        proxy_pass servidoresdb;
        proxy_connect_timeout 3s;
        proxy_timeout 10s;
    }
}"

# Borrado del archivo default de site-enabled
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default

    # Edición del archivo de configuración para el balanceador 
    sudo echo "$configuracion">>/etc/nginx/nginx.conf

    # Reinicio del servicio
    sudo systemctl restart nginx

fi

# Denegar el acceso a internet
sudo ip route del default
```

## Servidor de datos 1.

```
#! /bin/bash
sudo apt update

# Instalación de mariadb-server
echo "=========================================="
echo "Instalando el servidor de base de datos."
echo "=========================================="
sleep 1
sudo apt install -y mariadb-server

# Configuración de la base de datos
echo "=========================================="
echo "Configurando la base de datos."
echo "=========================================="
sleep 1

# Creación de la configuración
configuracion="
[galera]
wsrep_on                 = 1
wsrep_cluster_name       = \"MariaDB_Cluster\"
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_address    = gcomm://192.168.20.201,192.168.20.202
binlog_format            = row
default_storage_engine   = InnoDB
innodb_autoinc_lock_mode = 2

# Allow server to accept connections on all interfaces.
bind-address = 0.0.0.0
wsrep_node_address=192.168.20.201"

if [ ! -f $HOME/.flag ]; then
    # Creo la bandera para evitar que la configuración se vuelva a ejecutar.
    sudo touch $HOME/.flag
    sudo chmod +t $HOME/.flag

    # Configuración 50-server.cnf 
    sudo systemctl stop mariadb
    sudo echo "$configuracion">>/etc/mysql/mariadb.conf.d/50-server.cnf

    # Creación del cluster
    sudo galera_new_cluster
    sudo systemctl start mariadb
fi

# Denegar el acceso a internet
sudo ip route del default
```

## Servidor de datos 2.

```
#! /bin/bash
sudo apt update

# Instalación de mariadb-server
echo "=========================================="
echo "Instalando el servidor de base de datos."
echo "=========================================="
sleep 1
sudo apt install -y mariadb-server

# Configuración de la base de datos
echo "=========================================="
echo "Configurando la base de datos."
echo "=========================================="
sleep 1

# Creación de la configuración
configuracion="
[galera]
wsrep_on                 = 1
wsrep_cluster_name       = \"MariaDB_Cluster\"
wsrep_provider           = /usr/lib/galera/libgalera_smm.so
wsrep_cluster_address    = gcomm://192.168.20.201,192.168.20.202
binlog_format            = row
default_storage_engine   = InnoDB
innodb_autoinc_lock_mode = 2

# Allow server to accept connections on all interfaces.
bind-address = 0.0.0.0
wsrep_node_address=192.168.20.202"

if [ ! -f $HOME/.flag ]; then
    # Creo la bandera para evitar que la configuración se vuelva a ejecutar.
    sudo touch $HOME/.flag
    sudo chmod +t $HOME/.flag

    # Configuración 50-server.cnf 
    sudo systemctl stop mariadb
    sudo echo "$configuracion">>/etc/mysql/mariadb.conf.d/50-server.cnf

    sudo systemctl start mariadb

    # Creación de la base de datos y usuario para wordpress
    echo "=========================================="
    echo "Creando la base de datos y el usuario de wordpress."
    echo "=========================================="
    sleep 1
    sudo mysql -u root -e "CREATE DATABASE wp_db;"
    sudo mysql -u root -e "CREATE USER 'wp_usuario'@'192.168.20.%' IDENTIFIED BY 'wp1234';"
    sudo mysql -u root -e "GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_usuario'@'192.168.20.%';"
    sudo mysql -u root -e "FLUSH PRIVILEGES;"

fi

# Denegar el acceso a internet
sudo ip route del default

echo "==============================================================================================="
echo "Despliegue finalizado. Para acceder a su wordpress visita http://localhost:9090 en su navegador"
echo "==============================================================================================="
sleep 5
```

# Screencash.




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
