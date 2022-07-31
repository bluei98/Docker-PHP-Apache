# https://tecadmin.net/how-to-install-php-on-ubuntu-22-04/
# docker run -d -p 80:80 -p 443:443 --name web dadyzeus/webserver:ubuntu22.04-php8.1-apache
# docker build -t dadyzeus/webserver:ubuntu22.04-php8.1-apache . && docker run -it --rm -p 80:80 -p 443:443 dadyzeus/webserver:ubuntu22.04-php8.1-apache
FROM ubuntu:22.04

# 한국 전용
# RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
# RUN sed 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list.bak > /etc/apt/sources.list

# 레포지트 업데이트
RUN apt-get update -y
RUN apt-get upgrade -y

# 타임존 셋팅
RUN apt-get install -y tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# 기본 패키지 설치
RUN apt-get install -y gcc make telnet whois vim git gettext cron mariadb-client iputils-ping net-tools wget

# PHP 버젼 관리
# RUN apt-get install -y software-properties-common ca-certificates lsb-release apt-transport-https 
# RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

# Apache PHP 설치
RUN apt-get install -y apache2 apache2-utils libapache2-mod-php
RUN apt-get install -y php php-dev php-mysql php-mbstring php-curl php-gd php-imagick php-memcache php-xmlrpc php-zip composer

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

# # Apache Cache 설정
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

# SCRIPT
RUN echo 'service cron start\n/usr/sbin/apachectl -D FOREGROUND' > /entrypoint.sh

WORKDIR /var/www/html

VOLUME ["/var/www/html"]

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]