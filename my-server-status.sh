#!/bin/bash

echo '### MySQL:'
ps -ax | grep mysql
echo '### PHP:'
ps -ax | grep php-fpm 
echo '### httpd:'
ps -ax | grep httpd


