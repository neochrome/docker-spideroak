# SpiderOak Client
Used for headless backup/sync of important files with the [SpiderOak] service.

## Requirements
Docker Remote API v1.14 (Docker v1.2.x) or greater is required to discover mounted volumes.

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

#### configure
May be used to specify configuration for device setup on the command line.
Usage:
```
$ docker run ... neochrome/spideroak \
	configure \
		--user <username> \
		--password <password> \
		--device-name <device name> \
		[--no-create]
```
If no existing device is found, a new one is created unless `--no-create` is specified.

[SpiderOak]: https://spideroak.com
