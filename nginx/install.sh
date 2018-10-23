#!/bin/bash
###############################################
#
#  Bash script used to install mainline nginx 
#  compile with latest openssl.
# 
#  Author: PolyQY
#  Github: github.com/manyang901
#  Version: 0.1.0
#  Copyright PolyQY 2018
#
###############################################

NginxVersion=1.15.5
PcreVersion=8.42
ZlibVersion=1.2.11
OpensslVersion=1.1.1

if [[ ! 'Ubuntu'=~`cat /etc/*release` ]]
then
    echo -e "\033[31m[Error]:\033[0m Unsupported OS"
    exit 1
fi

sudo apt install gcc make unzip


# Get Nginx Source
wget http://nginx.org/download/nginx-${NginxVersion}.tar.gz
tar zxf nginx-${NginxVersion}.tar.gz

# Get Pcre library
wget https://ftp.pcre.org/pub/pcre/pcre-${PcreVersion}.zip
unzip pcre-${PcreVersion}.zip

# Get Zlib library
wget https://zlib.net/zlib-${ZlibVersion}.tar.gz
tar zxf zlib-${ZlibVersion}.tar.gz

# Get Openssl to compile
wget https://www.openssl.org/source/openssl-${OpensslVersion}.tar.gz
tar zxf openssl-${OpensslVersion}.tar.gz

# Install Geoip module
sudo apt install geoip-bin libgeoip-dev

cd nginx-${NginxVersion}

./configure \
--prefix=/usr/local/nginx \
--error-log-path=/data/wwwlogs/nginx_error.log \
--pid-path=/var/run/nginx.pid \
--user=www-data \
--group=www-data \
--build='with tls1.3' \
--without-http_scgi_module \
--without-http_uwsgi_module \
--with-file-aio \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_geoip_module \
--http-log-path=/data/wwwlogs/nginx_access.log \
--with-pcre=../pcre-${PcreVersion} \
--with-zlib=../zlib-${ZlibVersion} \
--with-openssl=../openssl-${OpensslVersion} \
--with-cc-opt='-O2' \
--with-cpu-opt=amd64

make && make install

cd ..

# Install Systemd startup script
cp init/nginx.service /etc/systemd/system/nginx.service
systemctl start nginx
systemctl enable nginx
