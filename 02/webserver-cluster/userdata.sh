#!/bin/bash
yum -y install httpd mod_ssl
echo "myweb" > /var/www/html/index.html
systemctl enable --now httpd.service
systemctl status httpd.service
