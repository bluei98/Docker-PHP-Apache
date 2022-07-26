# Docker Ubuntu-PHP-Apache

## Version
* Ubuntu 21.04
* PHP 7.4.16 with composer
* Apache 2.4.46

## Quick Start
```sh
$ docker run -d -p --rm 80:80 -p 443:443 dadyzeus/webserver:php7.4-apache
```

## Apache Modules
* ssl
* cache
* cache_disk
* expires
* headers
* rewrite

## PHP Modules