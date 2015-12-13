#!/bin/bash

DB_USER=admin
DB_PASS=changeme


MYSQL_IP=$LOCALDEV_PORT_3306_TCP_ADDR
MYSQL_PORT=3306


echo creating database $DB_NAME
mysql -h $MYSQL_IP -P $MYSQL_PORT -u admin -pchangeme -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

DB_HOST=$MYSQL_IP DB_NAME=$DB_NAME DB_USER=$DB_USER DB_PASS=$DB_PASS DB_PORT=$MYSQL_PORT /usr/bin/php /var/www/vendor/bin/phinx migrate -c /etc/phinx.php -e dev

