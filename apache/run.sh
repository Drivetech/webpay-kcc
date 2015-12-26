#!/bin/bash
composer install
chown www-data:www-data /var/www/webpay/log
apache2ctl -D FOREGROUND
