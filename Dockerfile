FROM phusion/baseimage:0.9.11
MAINTAINER botez <troyolson1@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

RUN usermod -u 99 nobody && \
    usermod -g 100 nobody

CMD ["/sbin/my_init"]

RUN apt-get install software-properties-common
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu trusty main'
RUN apt-get update -q

# Install sshd
RUN apt-get install -y openssh-server
#RUN mkdir /var/run/sshd

# Set password to 'admin'
RUN printf admin\\nadmin\\n | passwd

# Install MySQL
#RUN apt-get install -y mysql-server mysql-client libmysqlclient-dev
# Install MariaDB
RUN apt-get install -y mariadb-server

# Install Apache
RUN apt-get install -y apache2
# Install php
RUN apt-get install -y php5 libapache2-mod-php5 php5-mcrypt

# Install phpMyAdmin
RUN mysqld & \
	service apache2 start; \
	sleep 5; \
	printf y\\n\\n\\n1\\n | apt-get install -y phpmyadmin; \
	sleep 15; \
	mysqladmin -u root shutdown

RUN sed -i "s#// \$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = TRUE;#\$cfg\['Servers'\]\[\$i\]\['AllowNoPassword'\] = TRUE;#g" /etc/phpmyadmin/config.inc.php 

EXPOSE 22
EXPOSE 80
EXPOSE 3306

VOLUME /db

# Add mariadb to runit
RUN mkdir /etc/service/mariadb
ADD mariadb.sh /etc/service/mariadb/run
RUN chmod +x /etc/service/mariadb/run
