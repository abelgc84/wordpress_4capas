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

