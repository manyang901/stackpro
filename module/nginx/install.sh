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
ModulePath=${ModulePath}'/module/nginx'


# Detecting OS
# Only Support Ubuntu
if [[ ! 'Ubuntu'=~`cat /etc/*release` ]]
then
    echo -e "\033[31m[Error]:\033[0m Unsupported OS"
    exit 1
fi

# Install neccesary dependencies
echo -en "\033[34m[Info]:\033[0m Installing Build Dependencies......"
sudo apt-get install gcc g++ make unzip -y > /dev/null
echo 'Done'

# Get Nginx Source
echo -en "\033[34m[Info]:\033[0m Getting Nginx source......"
wget -q http://nginx.org/download/nginx-${NginxVersion}.tar.gz -O src/nginx-${NginxVersion}.tar.gz
tar zxf src/nginx-${NginxVersion}.tar.gz -C src
echo 'Done'

# Get Pcre library
echo -en "\033[34m[Info]:\033[0m Getting Pcre library......"
wget -q https://ftp.pcre.org/pub/pcre/pcre-${PcreVersion}.zip -O src/pcre-${PcreVersion}.zip
unzip -qo src/pcre-${PcreVersion}.zip -d src
echo 'Done'

# Get Zlib library
echo -en "\033[34m[Info]:\033[0m Getting Zlib library......"
wget -q https://zlib.net/zlib-${ZlibVersion}.tar.gz -O src/zlib-${ZlibVersion}.tar.gz
tar zxf src/zlib-${ZlibVersion}.tar.gz -C src
echo 'Done'

# Get Openssl to compile
echo -en "\033[34m[Info]:\033[0m Getting Openssl library......"
wget -q https://www.openssl.org/source/openssl-${OpensslVersion}.tar.gz -O src/openssl-${OpensslVersion}.tar.gz
tar zxf src/openssl-${OpensslVersion}.tar.gz -C src
echo 'Done'


# Install Geoip module
echo -en "\033[34m[Info]:\033[0m Installing Geoip library......"
sudo apt-get install geoip-bin libgeoip-dev -y > /dev/null
echo 'Done'

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

sudo make --quiet -j`nproc` 
sudo make install

cd ../..

# Install Systemd startup script
sudo cp ${ModulePath}/init/nginx.service /etc/systemd/system/nginx.service
sudo systemctl start nginx
sudo systemctl enable nginx
