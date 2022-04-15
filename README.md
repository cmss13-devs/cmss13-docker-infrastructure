## CM13 Docker Infrastructure Scripts  

These are scripts and tidbits that can be used to run a practical production setup using docker builds for the CM13 project.

This is very much a work in progress. Things are suboptimal and there are currently no guarantee anything in there works. Use at your own risk.

### Docker-Compose env quick-start

 The docker-compose env is an abstraction used for the setup of the cm13 docker containers.
 It allows us to manage the game setup as a whole.

 * pull, build, or tag an image as `cm13-live`
 * create a `docker-data-prod` volume (that will be mapped to game's `data/`)
 * put config files in `config/` which will be mapped into container
 * add additional resources as `cm-restricted-art/` and `cm-music/`
 * `docker-compose -f docker-cm13-production.yml up`, or use the systemd unit

### systemd unit quick start

 The systemd unit allows to have the docker-compose manaaged by the systemd daemon.
 It will keep restarting and recreating a new game container/env on each round.

 * `cp cm13.service /etc/systemd/system/`
 * `systemctl daemon-reload`
 * `systemctl enable cm13.service` - to run at boot
 * `systemctl start cm13.serivce` - to run it now
 * `systemctl status cm13.service` - to view status and check startup
 * `journalctl -xeu cm13.service` - to get detailed logs

### Overview

The systemd unit will automatically (re)start/create the container, recreating it with the newer tagged `cm13-live` image.

It is expected the game to terminate after end of round for this, or be forcefully made to.

In case of outside hard shutdown request, the systemd unit fist sends SIGINT which is translated by compose to SIGUSR1 in container to request DreamDaemon shutdown.

### Known Issues & TODO

 * Registry / Tag dynamic handling
 * Add instanciable systemd unit files - this will require using only volumes (no mapped files)
 * Double-check that the SININT/SIGUSR1 relibaly results in timely game shutdown (check for database deps?)
 * Include the database in this setup in the future
 * Add a watchdog for foreceful restart in systemd unit file

