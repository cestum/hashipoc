#!/bin/bash

apt-get install -y mariadb-server
mysqladmin -u root password R00tPassword
mysql -u root -p'R00tPassword' << EOF
GRANT ALL PRIVILEGES ON *.* TO 'vaultadmin'@'%' IDENTIFIED BY 'vaultadminpassword' WITH GRANT OPTION;
CREATE DATABASE app;
FLUSH PRIVILEGES;

EOF
sed -i 's/bind-address/#bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf
service mysql restart;
echo '{"service": {"name": "db", "tags": ["mysql"], "port":3306}}' | sudo tee /etc/consul/mysql.json
supervisorctl restart consul