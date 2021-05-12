#!/bin/bash
# Just starts testing environment for provided image
BASEDIR=`dirname "$0"`
TARGET_IMAGE="$1"
ESCAPED_NAME=`systemd-escape "$1"`
systemctl restart "cm13-testing@${ESCAPED_NAME}.service"
INSTANCE_URL=`${BASEDIR}/get-test-url.sh ${TARGET_IMAGE} 2>/dev/null`
echo $INSTANCE_URL
