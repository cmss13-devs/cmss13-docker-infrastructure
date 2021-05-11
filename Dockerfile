ARG SOURCE_IMAGE
FROM ${SOURCE_IMAGE}:latest
LABEL com.centurylinklabs.watchtower.enable="true"
# Add other peppering of production env here, eg. getting + mapping private sprites
