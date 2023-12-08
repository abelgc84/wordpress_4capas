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
    echo "==================================================="
    echo "Creando la base de datos y el usuario de wordpress."
    echo "==================================================="
    sleep 1
    sudo mysql -u root -e "CREATE DATABASE wp_db;"
    sudo mysql -u root -e "CREATE USER 'wp_usuario'@'192.168.20.%' IDENTIFIED BY 'wp1234';"
    sudo mysql -u root -e "GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_usuario'@'192.168.20.%';"
    sudo mysql -u root -e "FLUSH PRIVILEGES;"

fi

sudo systemctl start mariadb

# Denegar el acceso a internet
sudo ip route del default

echo "==============================================================================================="
echo "Despliegue finalizado. Para acceder a su wordpress visita http://localhost:9090 en su navegador"
echo "==============================================================================================="
sleep 5

