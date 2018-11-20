# StackPro

> This project is wrote for compiling latest Nginx mainline with newest feature such as tls1.3

This project support Nginx installation currently.
Suggest to use [OneinStack](https://github.com/lj2007331/oneinstack) to manage virtual host and do more lnmp stack installation.

## Usage

```
git clone https://github.com/manyang901/stackpro
cd stackpro
bash install.sh
```

## Installation Info

StackPro will allow you install latest Nginx mainline version with features

- Openssl 1.1.1
- tls1.3 enabled
- gcc O2 optimized

Running user: www-data
Installation path: /usr/local/nginx
Error log path:/data/wwwlogs/nginx_error.log
Access log path:/data/wwwlogs/nginx_access.log

Modules

- http_v2_module
- http_geoip_module
- http_sub_module
- http_ssl_module
- Disabled http_scgi_module
- Disabled http_uwsgi_module

System startup script is automatically installed using systemd.

Optimized Nginx configuration is also included


## License

This project is under GPLv3 license
