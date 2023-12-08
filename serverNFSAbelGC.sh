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