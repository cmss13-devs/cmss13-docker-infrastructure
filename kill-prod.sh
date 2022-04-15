#!/bin/bash
# Mimic'ing gpanel kill functionality
# but frankly if systemd is dead, you got bigger issues
cd /srv/cm13
docker-compose -f docker-cm13-production.yml -p cm13-live kill
