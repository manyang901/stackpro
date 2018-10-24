#!/bin/bash

###############################################
#
# Nginx install module
#
###############################################

NginxVersion=1.15.5
PcreVersion=8.42
ZlibVersion=1.2.11
OpensslVersion=1.1.1

ModulePath=$( $(cd $(dirname ${BASH_SOURCE[0]})); pwd)
echo $ModulePath


# Detecting OS
# Only Support Ubuntu
if [[ ! 'Ubuntu'=~`cat /etc/*release` ]]
then
    echo -e "\033[31m[Error]:\033[0m Unsupported OS"
    exit 1
fi

# Install neccesary dependencies
echo 'Install Build Dependencies......'
sudo apt install gcc g++ make unzip >/dev/null
echo 'Done.'

# Get Nginx Source
wget http://nginx.org/download/nginx-${NginxVersion}.tar.gz -O src/nginx.tar.gz
tar zxf nginx.tar.gz

# Get Pcre library
wget https://ftp.pcre.org/pub/pcre/pcre-${PcreVersion}.zip -O pcre.zip
unzip pcre.zip

# Get Zlib library
wget https://zlib.net/zlib-${ZlibVersion}.tar.gz -O zlib.tar.gz
tar zxf zlib.tar.gz

# Get Openssl to compile
wget https://www.openssl.org/source/openssl-${OpensslVersion}.tar.gz -O openssl.tar.gz
tar zxf openssl.tar.gz

# Install Geoip module
sudo apt install geoip-bin libgeoip-dev

cd src/nginx-${NginxVersion}

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

cd ../..

# Install Systemd startup script
cp ${ModulePath}/init/nginx.service /etc/systemd/system/nginx.service
systemctl start nginx
systemctl enable nginx
