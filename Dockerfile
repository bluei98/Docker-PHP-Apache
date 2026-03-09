FROM ubuntu:24.04

# 레포지트 업데이트
RUN apt-get update -y && apt-get upgrade -y

# 타임존 셋팅
RUN apt-get install -y tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# 기본 패키지 설치
RUN apt-get install -y gcc make telnet whois vim git gettext cron mariadb-client iputils-ping net-tools wget software-properties-common ca-certificates lsb-release apt-transport-https

# PHP 8.4 설치를 위한 PPA 추가
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y && apt-get update -y

# Apache + PHP 8.4 설치
RUN apt-get install -y apache2 apache2-utils libapache2-mod-php8.4
RUN apt-get install -y php8.4 php8.4-dev php8.4-mysql php8.4-mbstring php8.4-curl php8.4-gd php8.4-imagick php-memcache php8.4-xmlrpc php8.4-zip php-redis composer

# 라이브러리 설치
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
RUN a2enmod cache cache_disk expires headers rewrite

# Make php info page
RUN rm /var/www/html/index.html
COPY index.php /var/www/html/index.php

# Default Setting File Add
COPY default.conf /etc/apache2/sites-enabled/000-default.conf
COPY default-ssl.conf /etc/apache2/sites-enabled/000-default-ssl.conf

# Ioncube Loader (PHP 8.4 버전)
RUN mkdir /root/tmp
RUN wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O /root/tmp/ioncube_loaders_lin_x86-64.tar.gz
RUN tar -zxvf /root/tmp/ioncube_loaders_lin_x86-64.tar.gz -C /root/tmp
RUN cp /root/tmp/ioncube/ioncube_loader_lin_8.4.so /usr/lib/php/20240902
RUN echo "zend_extension = /usr/lib/php/20240902/ioncube_loader_lin_8.4.so" >> /etc/php/8.4/apache2/php.ini
RUN echo "zend_extension = /usr/lib/php/20240902/ioncube_loader_lin_8.4.so" >> /etc/php/8.4/cli/php.ini

# GeoIP Download
COPY GeoLite2-City.mmdb /usr/share/GeoIP/GeoLite2-City.mmdb

# Cron 설정: 1분마다 /var/www/html/cron.php 실행
RUN echo "* * * * * php /var/www/html/cron.php > /dev/null 2>&1" >> /etc/crontab

# Entrypoint
RUN echo 'service cron start\n/usr/sbin/apachectl -D FOREGROUND' > /entrypoint.sh

WORKDIR /var/www/html
VOLUME ["/var/www/html"]

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
