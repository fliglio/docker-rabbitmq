FROM ubuntu:16.04

# Ensure UTF-8
RUN apt-get clean && apt-get update --fix-missing && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "`
RUN apt-get update

RUN apt-get -y install python-software-properties
RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update

RUN apt-get install -y php5.6

RUN add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty universe'
RUN apt-get update
RUN apt-get install -y \
	php5.6-cli php5.6-fpm php5.6-mysql php5.6-pgsql php5.6-sqlite php5.6-curl \
	php5.6-gd php5.6-mcrypt php5.6-intl php5.6-imap php5.6-tidy php5.6-memcache \
	php5.6-dom
RUN apt-get install -y \
	nginx \
	memcached \
	mysql-server-5.6 mysql-client-5.6 \
	supervisor \
	less

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/5.6/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/5.6/cli/php.ini

RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/www

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/5.6/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/5.6/fpm/php.ini
 
ADD nginx-site   /etc/nginx/sites-available/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stdout /var/log/nginx/error.log

# mysql
RUN apt-get clean
#RUN chmod 777 /var/run/mysqld/mysqld.sock
RUN ls /var/run/
RUN chown -R mysql:mysql /var/lib/mysql /usr/sbin/mysqld /usr/bin/mysql /var/run/mysqld
RUN chgrp -R mysql /var/lib/mysql /usr/bin/mysql /var/run/mysqld
RUN find /var/lib/mysql -type f -exec touch {} +
RUN find /usr/sbin/mysqld -type f -exec touch {} +


RUN service mysql stop
#RUN mkdir /var/run/mysqld
RUN chown mysql:mysql /var/run/mysqld
RUN /usr/sbin/mysqld --skip-grant-tables --skip-networking &

#RUN service mysql restart
#; exit 0

RUN less /var/log/mysql/error.log

RUN /usr/sbin/mysqld --user=root & \
	sleep 10s &&\
	echo "GRANT ALL ON *.* TO admin@'%' IDENTIFIED BY 'changeme' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

RUN cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf
RUN sed -i -e "s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf


# consul
RUN apt-get install -y unzip
ADD https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_linux_amd64.zip /tmp/consul.zip
RUN cd /tmp && unzip consul.zip && chmod 755 consul && mv consul /bin/consul && rm consul.zip

ADD https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_web_ui.zip /tmp/webui.zip
RUN mkdir /ui && cd /ui && unzip /tmp/webui.zip && rm /tmp/webui.zip

# rabbitmq
RUN apt-get install -y rabbitmq-server
RUN rabbitmq-plugins enable rabbitmq_management

# chinchilla
RUN apt-get install unzip
RUN apt-get install -y curl
ADD http://www.chaoticharmony.net/chinchilla/chinchilla-master.zip /tmp/chinchilla-master.zip
RUN cd /tmp && unzip chinchilla-master.zip && chmod 755 chinchilla-master && mv chinchilla-master /bin/chinchilla

ADD configure-chinchilla.sh /tmp/configure-chinchilla.sh

# configure
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD phinx.php /etc/phinx.php
ADD migrate.sh /usr/local/bin/migrate.sh
ADD run.sh /usr/local/bin/run.sh

EXPOSE 80
EXPOSE 3306
EXPOSE 8500
EXPOSE 15672
EXPOSE 5672

CMD ["/usr/local/bin/run.sh"]

