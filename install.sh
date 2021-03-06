#!/bin/bash

##############################################
#
# This is a project used to install latest LNMP
# or LNMP liked stack with advanced feature.
#
# Author: PolyQY
# Github: https://github.com/manyang901/stackpro
# Version: 0.1.0
# Blog: https://kucloud.win
# Copyringt 2018 @PolyQY
#
##############################################

set -o errexit

RootPath=$(dirname $(readlink -f $0))
isInstallNginx=''
until [[ ${isInstallNginx} = 'y' || ${isInstallNginx} = 'n' ]]
do
read -p 'Install Nginx?(y/n): ' isInstallNginx
done

if [ ${isInstallNginx} = 'y' ]; then
    source module/*/install.sh
fi

echo 'Thank you for using StackPro!'
