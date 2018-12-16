#!/bin/bash

###############################################
#
# Nginx install module
#
###############################################

# Get Latest Nginx Version Automatically
Nginx_VER_ORIG=$(wget -qO- https://nginx.org/packages/mainline/ubuntu/pool/nginx/n/nginx/ | grep -o 'nginx_[^"]*' | grep -v '</a>' | grep 'dsc$' | sort -nk 2 -t . | grep 'bionic' | tail -n1 | cut -d'-' -f1)

# Pre Define Version
PcreVersion=8.42
ZlibVersion=1.2.11
OpensslVersion=1.1.1a

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
sudo apt-get install sudo gcc g++ make unzip -y > /dev/null
echo 'Done'

# Get Nginx Source
echo -en "\033[34m[Info]:\033[0m Getting Nginx source......"
wget -q https://nginx.org/packages/mainline/ubuntu/pool/nginx/n/nginx/${Nginx_VER_ORIG}.orig.tar.gz -O src/${Nginx_VER_ORIG}.tar.gz
tar zxf src/${Nginx_VER_ORIG}.tar.gz -C src
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

# Get Openssl library
echo -en "\033[34m[Info]:\033[0m Getting Openssl library......"
wget -q https://www.openssl.org/source/openssl-${OpensslVersion}.tar.gz -O src/openssl-${OpensslVersion}.tar.gz
tar zxf src/openssl-${OpensslVersion}.tar.gz -C src
echo 'Done'


# Install Geoip module
echo -en "\033[34m[Info]:\033[0m Installing Geoip module......"
sudo apt-get install geoip-bin libgeoip-dev -y > /dev/null
echo 'Done'

cd src/nginx-$(echo ${Nginx_VER_ORIG} | cut -d'_' -f2)

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
--with-http_sub_module \
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
sudo cp ${ModulePath}/conf/nginx.conf /usr/local/nginx/conf/nginx.conf
sudo systemctl start nginx
sudo systemctl enable nginx
