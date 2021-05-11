#!/bin/bash
# Just pull a diff source to be used by the production setup for next restart
# If unspecified, updates the tag with current set image source
IMAGE_SOURCE=${1:$(cat image-source)}
docker pull "$1" && echo "$1" > $(dirname "$0")/image-source && docker tag "$1" cm13-live
