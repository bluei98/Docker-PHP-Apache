# Docker Ubuntu-PHP-Apache

## Version
* Ubuntu 20.04
* PHP 7.4.16 with composer
* Apache 2.4.46

## Quick Start
```sh
$ docker run -d --rm -p 80:80 -p 443:443 dadyzeus/webserver:ubuntu20.04-php7.4-apache2.4
```

## Apache Modules
* ssl
* cache
* cache_disk
* expires
* headers
* rewrite