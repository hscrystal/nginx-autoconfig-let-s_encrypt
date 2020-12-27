#!/bin/bash

set -e

DOMAIN=""
PROXY_HOST=""
PROXY_PORT=""

BASE_DIR="/etc/nginx/sites-available/"
CERT_DIR="/etc/letsencrypt/live/"
TEMP_FILE="./template.conf"

check_template_config () {
	if [ ! -f ${TEMP_FILE} ]; then
		echo "Template is not exist"
		exit 1
	fi
}

check_file_config_exist () {
	if [ -f ${BASE_DIR}$DOMAIN.conf ]; then
		echo "File configuration is exist in ${BASE_DIR}"
		exit 1
	fi
}

check_domain () {
	if [ -z "$DOMAIN" ]; then
		echo "Domain is empty."
		exit 1
	fi
}

check_host () {
	if [ -z "$PROXY_HOST" ]; then
		echo "Host is empty."
		exit 1
	fi
}

check_port () {
	if [ -z "$PROXY_PORT" ]; then
		echo "Port is empty."
		exit 1
	fi
}

do_new_config () {
	NEW_FILE=$BASE_DIR$DOMAIN.conf
	sudo cp $TEMP_FILE $NEW_FILE
	sudo sed -i "s/www.example.com/$DOMAIN/g" $NEW_FILE
	sudo sed -i "s/127.0.0.1:80/$PROXY_HOST:$PROXY_PORT/g" $NEW_FILE
	sudo ln -s $NEW_FILE /etc/nginx/sites-enabled
}

do_create_cert () {
	sudo certbot certonly --webroot -d $DOMAIN --email it@example.com -w /var/www/_letsencrypt -n --agree-tos --force-renewal
	if [ ! -d  $CERT_DIR$DOMAIN ]; then
		echo "Certbot fails Ceate Certificate"
		exit 1
	fi
}

while getopts d:h:p: flag
do
	case "${flag}" in
		d) DOMAIN=${OPTARG};;
		h) PROXY_HOST=${OPTARG};;
		p) PROXY_PORT=${OPTARG};;
	esac
done

# Check Input Parameter
check_domain
check_host
check_port

# Create File Configuration
check_template_config
check_file_config_exist
do_new_config

# Create Certificate by Let's Encrypt
do_create_cert

echo "`date` Cteate Domain: $DOMAIN Finish"
