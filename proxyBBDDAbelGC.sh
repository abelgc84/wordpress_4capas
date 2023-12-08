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