#!/bin/bash

VER=
PASSWORD=
while getopts v:p: flag
do
    case "${flag}" in
        v) VER=${OPTARG};;
        p) PASSWORD=${OPTARG};;
    esac
done

if [ -z $VER ] ; then
    echo -e "\033[0;31m \n error:\033[0m version (-v) flag required"
    echo -e "\033[0;36m Usage:\033[0m ./build.sh -v 8.0.0 -p CURITY_ADMIN_PASSWORD_HERE\n"
    exit 1
fi

if [ -z $PASSWORD ] ; then
    echo -e "\033[0;31m \n error:\033[0m curity admin password (-p) flag required"
    echo -e "\033[0;36m Usage:\033[0m ./build.sh -v 8.0.0 -p qwerty\n"
    exit 1
fi

echo -e "\nBuilding custom image : \033[0;36m curity-idsvr:$VER \033[0m "
echo -e "based on image : \033[0;36m curity.azurecr.io/curity/idsvr:$VER \033[0m \n"

docker_compose_up()
{   # passing CURITY_VERSION and PASSWORD variables to docker compose
    CURITY_VERSION=$VER  PASSWORD=$PASSWORD sudo -E docker compose up --build
}

docker_compose_up