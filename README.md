# SpiderOak Client
Used for headless backup/sync of important files with the [SpiderOak] service.

## Usage
Launch a container from the image with `/var/run/docker.sock` mounted as `/docker.sock`.

When no previous configuration is found, an interactive session will initiate to setup a
device with the [SpiderOak] service.

If settings should be persisted across container re-creation, a VOLUME `/spideroak` may be mounted.

Any additional MOUNTs, or VOLUMEs from other containers, will be included for backup/syncing.

E.g:
```
$ docker run -it \
	-v /var/run/docker.sock:/docker.sock:ro \
	--volumes-from=spideroak-settings \
	--volumes-from=archive \
	neochrome/spideroak
```
Will result in settings persisted in the `spideroak-settings` data container, and backup/syncing of
any VOLUMEs from the `archive` container.

[SpiderOak]: https://spideroak.com
