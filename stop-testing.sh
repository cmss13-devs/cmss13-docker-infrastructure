#!/bin/bash
# Just starts testing environment for provided image
ESCAPED_NAME=`systemd-escape "$1"`
systemctl stop "cm13-testing@${ESCAPED_NAME}.service"
