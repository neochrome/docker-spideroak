# SpiderOak Client
Used for headless backup/sync of important files with the [SpiderOak] service.

## Usage
Launch a container from the image with `/var/run/docker.sock` mounted as `/docker.sock`.

When no previous configuration is found, an interactive session will initiate to setup a
device with the [SpiderOak] service. In order to skip the interactive setup, a configuration file
(json formatted) may be supplied by piping it to the container: `cat config.json | docker run -t ...`

Example configuration file:
```json
{
	"username": "username",
	"password": "password",
	"reinstall": true,
	"device_name": "device"
}
```
See <https://spideroak.com/faq/how-do-i-set-up-a-new-device-from-the-command-line> for more info.

If settings should be persisted across container re-creation, a VOLUME `/spideroak` may be mounted.

Any additional MOUNTs, or VOLUMEs from other containers, will be included for backup/syncing.

E.g:
```sh
$ docker run -it \
	-v /var/run/docker.sock:/docker.sock:ro \
	--volumes-from=spideroak-settings \
	--volumes-from=archive \
	neochrome/spideroak
```
Will result in settings persisted in the `spideroak-settings` data container, and backup/syncing of
any VOLUMEs from the `archive` container.

[SpiderOak]: https://spideroak.com
