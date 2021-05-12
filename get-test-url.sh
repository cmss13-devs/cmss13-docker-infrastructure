#!/bin/bash
# Detect listening port mapping assigned by docker, and return a BYOND link with public IP
BASEDIR=`dirname "$0"`
TARGET_IMAGE="$1"
LISTENSPEC=`docker-compose -f "${BASEDIR}/docker-cm13-testing.yml" -p "cm13-testing-${TARGET_IMAGE}" port cm13-game 1400 2> /dev/null`
PORTSPEC=`echo $LISTENSPEC | cut -d':' -f2 2> /dev/null`
PUBLICADDR=`ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p' 2> /dev/null`
if [[ $PUBLICADDR =~ [0-9\.:]+ ]] && [[ $PORTSPEC =~ [0-9]+ ]]; then
	echo "byond://${PUBLICADDR}:${PORTSPEC}"
fi
