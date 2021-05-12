#!/bin/bash
# Just starts testing environment for provided image
TARGET_IMAGE="$1"
ESCAPED_NAME=`systemd-escape "$1"`
systemctl start "cm13-testing@${ESCAPED_NAME}.service" > /dev/null

