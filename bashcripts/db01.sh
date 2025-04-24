#!/bin/bash

DATABASE_PASS='admin123'

# Update & Install necessary packages
sudo apt update && sudo apt install -y git zip unzip mariadb-server

# Start & Enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Set root password and configure database
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DATABASE_PASS}';"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -u root -p"$DATABASE_PASS" -e "DROP DATABASE IF EXISTS test;"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;"
sudo mysql -u root -p"$DATABASE_PASS" -e "CREATE DATABASE accounts;"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';"
sudo mysql -u root -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin123';"

# Clone project dan restore database
cd /tmp/
git clone -b main https://github.com/mdsykr8894/vprofile-project.git
sudo mysql -u root -p"$DATABASE_PASS" accounts < /tmp/vprofile-project/src/main/resources/db_backup.sql
