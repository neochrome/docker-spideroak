#!/bin/sh
set -e

export HOME=/spideroak
mkdir -p $HOME

function log () {
	printf '%s %s\n' $(date --utc +'%Y-%m-%dZ%T.%N') "$*"
}

function configured () {
	[[ ! "$(SpiderOak --userinfo)" =~ 'New User Setup' ]]
}

function configure () {
	shift;
	options=$(getopt -o 'u:p:d:C' -l 'user:,password:,device-name:,no-create' -- "$@")
	[ $? -eq 0 ] || {
		log 'incorrect configuration options provided'
		exit 1
	}
	no_create=0
	user=''
	password=''
	device_name=''
	eval set -- "$options"
	while true; do
		case "$1" in
			-u|--user) shift; user="$1";;
			-p|--password) shift; password="$1";;
			-d|--device-name) shift; device_name="$1";;
			-C|--no-create) no_create=1;;
			--) shift;break;;
		esac
		shift
	done
	[[ -z "$user" ]] || [[ -z "$password" ]] || [[ -z "$device_name" ]] && {
		log '--user, --password and --device-name must all be specified'
		exit 1
	}

	function configure_for_reinstall () {
		cat > /config.json <<EOF
		{
			"username": "$user",
			"password": "$password",
			"reinstall": $1,
			"device_name": "$device_name"
		}
EOF
		output=$(SpiderOak --setup=/config.json)
		rm -f /config.json
		[[ "$output" =~ 'batchmode run complete: shutting down' ]] && return 0
		log "$output"
		return 1
	}

	log "trying to configure as existing device: $device_name"
  configure_for_reinstall 'true' || {
		[[ $no_create -eq 0 ]] || {
			log 'no_create specified, aborting'
			exit 1
		}
		log "trying to configure as new device: $device_name"
		configure_for_reinstall 'false' || {
			log 'configuration failed'
			exit 1
		}
	}
	SpiderOak --exclude-dir='/spideroak/SpiderOak Hive'
	log 'configuration done'
	exit 0
}

case "$1" in
	# commands that don't require proper configuration
	-h|--help|--version|--setup)
		SpiderOak "$@"
		exit 0
		;;

	--is-configured)
		configured && exit 0 || exit 1
		;;

	configure)
		if configured; then
			log 'already configured, aborting'
			exit 1
		fi
		configure "$@"
		;;

	*)
		if ! configured; then
			log 'not configured, aborting'
			exit 1
		fi
		log 'resetting included folders'
		SpiderOak --reset-selection >/dev/null
		for f in $(lsdvol --docker-socket /docker.sock); do
			[[ "$f" = "/docker.sock" ]] && continue
			[[ "$f" = "/spideroak" ]] && continue
			log "  include folder: $f"
			SpiderOak --include-dir="$f" >/dev/null
		done

		log "launching with params: $*"
		SpiderOak "$@"
		;;

esac
