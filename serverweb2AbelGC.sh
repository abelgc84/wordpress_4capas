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