#!/bin/bash

# Provision an Ubuntu box with an Nginx / PHP installation

# Nginx settings
NGINX_DOCUMENT_ROOT="\/vagrant\/web"
NGINX_LOG_DIR="\/vagrant\/logs"
NGINX_USER="www-data"
NGINX_FRAMEWORK="1"
NGINX_FRAMEWORK_ROOT="index.php"

# MySQL settings
MYSQL_ROOT_PASSWORD="root"

# --Require the functions file
source /vagrant/env/functions.sh

# Are we provisioned?
if [ -e "/home/vagrant/.provisioned" ]; then
    output $BLUE "Box already provisioned."; exit 0
fi

# # --Update the box
box_update

# # --Install required software
output $BLUE "Installing software..."
apt-get -qq -y install nginx mysql-server php5 php5-cgi php5-cli php5-mysql spawn-fcgi
output $GREEN "Software installed."

# --Setup the software

# Hostname
echo "$1" > /etc/hostname
sed -i "s/precise32/$1/" /etc/hosts
service hostname start

# Nginx
output $BLUE "Setting up Nginx..."
cp /vagrant/env/support/nginx.conf /etc/nginx/nginx.conf
sed -i "s/{USER}/$NGINX_USER/" /etc/nginx/nginx.conf
cp /vagrant/env/support/nginx-site.conf /etc/nginx/sites-available/vagrant
sed -i "s/{DOCUMENT_ROOT}/$NGINX_DOCUMENT_ROOT/g" /etc/nginx/sites-available/vagrant
sed -i "s/{LOG_DIR}/$NGINX_LOG_DIR/g" /etc/nginx/sites-available/vagrant
if [ "$NGINX_FRAMEWORK" -eq "1" ]; then
    sed -i "s/{FRAMEWORK}//g" /etc/nginx/sites-available/vagrant
    sed -i "s/{FRAMEWORK_ROOT}/$NGINX_FRAMEWORK_ROOT/g" /etc/nginx/sites-available/vagrant
else
    sed -i "s/{FRAMEWORK}/#/g" /etc/nginx/sites-available/vagrant
fi
ln -s /etc/nginx/sites-available/vagrant /etc/nginx/sites-enabled/
service nginx restart
output $GREEN "Finished configuring Nginx."

# PHP
output $BLUE "Setting up PHP..."
cp /vagrant/env/support/php.ini /etc/php5/cgi/
cp /vagrant/env/support/php.ini /etc/php5/cli/
cp /vagrant/env/support/php-fastcgi /etc/init.d/php-fastcgi
sed -i "s/{USER}/$NGINX_USER/g" /etc/init.d/php-fastcgi
chmod +x /etc/init.d/php-fastcgi
/etc/init.d/php-fastcgi start
update-rc.d php-fastcgi defaults
output $GREEN "Finished configuring PHP."

# MySQL
output $BLUE "Setting up MySQL..."
cp /vagrant/env/support/my.cnf /etc/mysql/my.cnf
mysqladmin -u root password $MYSQL_ROOT_PASSWORD
echo "create user 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD';" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "grant all privileges on *.* to 'root'@'%' with grant option;" | mysql -u root -p$MYSQL_ROOT_PASSWORD
echo "flush privileges;" | mysql -u root -p$MYSQL_ROOT_PASSWORD
service mysql restart
output $GREEN "Finished configuring MySQL."

# --Optional software

# ZSH
box_install_zsh

# -- Register the box
box_register

output $GREEN "Box provisioned."