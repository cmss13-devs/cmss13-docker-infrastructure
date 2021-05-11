#!/bin/bash
# Just pull a diff source to be used by the production setup for next restart
# If unspecified, updates the tag with current set image source
BASEDIR=`dirname "$0"`
CURRENT_IMAGE_SOURCE=`cat ${BASEDIR}/image-source`
IMAGE_SOURCE="${1:-$CURRENT_IMAGE_SOURCE}"
docker pull "${IMAGE_SOURCE}"
echo "${IMAGE_SOURCE}" > ${BASEDIR}/image-source
docker tag "${IMAGE_SOURCE}" cm13-live
