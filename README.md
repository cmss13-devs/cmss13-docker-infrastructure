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

### Performance considerations

#### a. Networking Overhead

Docker networking overhead can be expensive at high PPS rates. This is not normally a major issue for DD even at 200+ players, but we use host networking in the setup by default as isolation in that vein is not really needed for our usecase.

#### b. Seccomp Syscall Overhead

Making syscalls in Docker can induce major overhead due to extra securty features, notably Seccomp. This should still not be a major issue for SS13/BYOND compared to other factors, but it can technically b disabled using `--privileged` on docker commandline, or `security_opt: seccomp:unconfined` as commented in the compose file. This shouldn't be done lightly as it cuts on a major source of docker isolation!

#### c. Timing Overhead

Seccomp Syscall overhead is not normally a major issue because of mechanisms to go around this eg. vDSO. **Unfortunatly, this is not always available.** One of such problems we've encountered were `gettimeofday` and `clock_gettime` calls: **depending on clock source, vDSO might not be available and result in constant syscalls by the DM runtime**. This is problematic for this setup, because doing thousands of such calls per second (and even more with profiler enabled!) will be **cripling performance**. 

This is solveable by simply using a different clock source systemwide, eg. on Linux TSC with the following kernel boot arguments: `clocksource=tsc tsc=reliable`

See [this article for details](https://careers.appian.com/blog/the-tech-corner/yet-another-reason-your-docker-containers-may-be-slow-on-ec2-clock_gettime-gettimeofday-and-seccomp/) or [this EC2 documentation page for instructions](https://aws.amazon.com/premiumsupport/knowledge-center/manage-ec2-linux-clock-source/) 


### Known Issues & TODO

 * Registry / Tag dynamic handling
 * Add instanciable systemd unit files - this will require using only volumes (no mapped files)
 * Double-check that the SININT/SIGUSR1 relibaly results in timely game shutdown (check for database deps?)
 * Include the database in this setup in the future
 * Add a watchdog for foreceful restart in systemd unit file

