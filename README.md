## CM13 Docker Infrastructure Scripts  

These are scripts and tidbits that can be used to run a practical production setup using docker builds for the CM13 project.

This is very much a work in progress. Things are suboptimal and there are currently no guarantee anything in there works. Use at your own risk.

### Contents

 * `cm13.service` contains a simple systemd unit template for interacting with the docker-compose environment
 * `docker-cm13-production.yml` contains a sample docker-compose environment. As of current this is only the game container itself, other services are still managed separately.
 * `build-image.sh` is an awful proof-of-concept local image build script to pull/rebase several repositories for testmerging into an usable image
 * `repositories/` is used as local caching for build repositories by `build-image.sh`

### docker-compose environment quick start

 * pull or build an image to run as `cm13-live`
 * create a `cm13-data-prod` docker data volume that will be mapped to `data/`
 * put config folder for the game in same directory as `config/` - ensuring external database config is correct
 * add custom icons/sounds as `cm-restricted-art/` and `cm-music/` (pending changes)
 * `docker-compose -f docker-cm13-production.yml up`, or use the systemd unit

### systemd unit quick start

 * Toss `cm13.service` in a location such as `/etc/systemd/system/`
 * run `systemctl daemon-reload`
 * enable service to run automatically with `systemctl enable cm13`
 * start it with `systemctl start cm13`
 * you can view the status with `systemctl status cm13`

### Overview

The systemd unit will automatically start & restart the docker-compose environment. On round end, the server is expected to shut down (or forcibly be made to, watchdog TBD), destroying the container, causing recreation of the environment with any updated image tagged `cm13-live`. The systemd unit uses a docker-compose instance of the same name by default but you can used instanciated units to run more than one game instance, etc.

The whole thing is obviously suspect to future changes for practical reasons (notably the awful build process, replacing/removing the systemd unit to leverage docker directly, etc)

### Known issues

This is still very WIP. Ideally the image build process should be delegated to a proper application such as gpanel or other, and not done by this wacky script, allowing for proper management. This could involve setting up a registry (or not). In addition, shutting down the docker-compose environment from systemd does not seem to currently completely work as intended: BYOND will follow the SIGUSR1 signal to shut down but may fail to.
