# SpiderOak Client
Used for headless backup/sync of important files with the [SpiderOak] service.

## Usage
Launch a container from the image with `/var/run/docker.sock` mounted as `/docker.sock`,
this enables auto-detection of other mounted volumes to backup/sync.
Regular [SpiderOak] options and parameters are supported.

E.g:
```sh
$ docker run -it \
	-v /var/run/docker.sock:/docker.sock:ro \
	--volumes-from=archive \
	neochrome/spideroak
```

## Settings / configuration
The regular `--setup` command is available for use, but included are also two
complimentary commands which might be helpful when setting up your account.
If settings should be persisted across container re-creation, a VOLUME
`/spideroak` may be mounted.

#### --is-configured
Used to check if a proper configuration exists. Exits with zero if a configuration
exists, otherwise non-zero.

#### --configure
May be used to either launch an interactive setup/configuration session (same as
`--setup=-`, or to read settings formatted as json on stdin by piping it to the
container: `cat config.json | docker run -t ...`

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

[SpiderOak]: https://spideroak.com
