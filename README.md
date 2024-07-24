# Docker Ubuntu-PHP-Apache

## Version
* Ubuntu 22.04
* PHP 8.1.2 with composer
* Apache 2.4.46

## Quick Start
```sh
$ docker build . -t dadyzeus/webserver:ubuntu22.04-php8.1-apache2.4 -t dadyzeus/webserver:latest
$ docker run -d --rm -p 80:80 -p 443:443 dadyzeus/webserver:latest
```


## Apache Modules
* ssl
* cache
* cache_disk
* expires
* headers
* rewrite