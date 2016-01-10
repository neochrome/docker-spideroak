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

case "$1" in
	# commands that don't require proper configuration
	-h|--help|--version|--setup)
		SpiderOak "$@"
		exit 0
		;;

	--is-configured)
		configured && exit 0 || exit 1
		;;

	--configure)
		if configured; then
			log 'already configured, aborting'
			exit 1
		fi
		log 'configuration initiated'
		if [[ -t 1 ]]; then
			log 'launching interactive setup'
			SpiderOak --setup=-
		else
			log 'reading configuration from stdin'
			cat > /config.json
			SpiderOak --setup=/config.json
			rm /config.json
		fi
		log 'configuration done'
		exit 0
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
