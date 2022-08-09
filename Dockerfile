FROM ubuntu:20.04

# hirsute to focal
# RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
# RUN sed 's/hirsute/neotic/g' /etc/apt/sources.list.bak > /etc/apt/sources.list

# # 레포지트 업데이트
RUN apt-get update -y
RUN apt-get upgrade -y

# 타임존 셋팅
RUN apt-get install -y tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# 기본 패키지 설치
RUN apt-get install -y gcc make telnet whois vim git gettext cron mariadb-client iputils-ping net-tools wget

# # Apache PHP 설치
RUN apt-get install -y apache2 apache2-utils
RUN apt-get install -y php php-dev libapache2-mod-php php-mysql php-pear php-mbstring php-curl php-gd php-imagick php-memcache php-xmlrpc php-geoip php-zip composer

# # 라이브러리 설치
RUN pear install MIME_Type

# SSL 서비스 설정
RUN a2enmod ssl
RUN mkdir /etc/apache2/ssl
RUN openssl genrsa -out /etc/apache2/ssl/server.key 2048
RUN openssl req -new -days 365 -key /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.csr -subj "/C=KR/ST=Daejeon/L=Daejeon/O=Docker/OU=IT Department/CN=localhost"
RUN openssl x509 -req -days 365 -in /etc/apache2/ssl/server.csr -signkey /etc/apache2/ssl/server.key -out /etc/apache2/ssl/server.crt
RUN sed 's/\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/\/etc\/apache2\/ssl\/server.crt/g' /etc/apache2/sites-available/default-ssl.conf > /etc/apache2/sites-available/default-ssl.conf.tmp
RUN sed 's/\/etc\/ssl\/private\/ssl-cert-snakeoil.key/\/etc\/apache2\/ssl\/server.key/g' /etc/apache2/sites-available/default-ssl.conf.tmp > /etc/apache2/sites-enabled/000-default-ssl.conf
RUN rm /etc/apache2/sites-available/default-ssl.conf.tmp -f

# Apache Cache 설정
RUN a2enmod cache
RUN a2enmod cache_disk
RUN a2enmod expires
RUN a2enmod headers
RUN a2enmod rewrite

# Make php info page
RUN rm /var/www/html/index.html
COPY index.php /var/www/html/index.php

# Default Setting File Add
# RUN wget https://raw.githubusercontent.com/bluei98/Docker-PHP-Apache/master/default.conf  -O /etc/apache2/sites-enabled/000-default.conf
# RUN wget https://raw.githubusercontent.com/bluei98/Docker-PHP-Apache/master/default-ssl.conf  -O /etc/apache2/sites-enabled/000-default-ssl.conf
COPY default.conf /etc/apache2/sites-enabled/000-default.conf
COPY default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf

# IonCube 설치
RUN mkdir /root/tmp 
RUN cd /root/tmp
RUN wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O /root/tmp/ioncube_loaders_lin_x86-64.tar.gz
RUN tar -zxvf /root/tmp/ioncube_loaders_lin_x86-64.tar.gz -C /root/tmp
RUN cp /root/tmp/ioncube/ioncube_loader_lin_7.4.so /usr/lib/php/20190902
RUN echo "zend_extension = /usr/lib/php/20190902/ioncube_loader_lin_7.4.so" >> /etc/php/7.4/apache2/php.ini
RUN echo "zend_extension = /usr/lib/php/20190902/ioncube_loader_lin_7.4.so" >> /etc/php/7.4/cli/php.ini

# SCRIPT
RUN echo 'service cron start\n/usr/sbin/apachectl -D FOREGROUND' > /entrypoint.sh

WORKDIR /var/www/html

VOLUME ["/var/www/html"]

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]