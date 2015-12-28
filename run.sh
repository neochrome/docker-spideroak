#!/bin/sh
set -e

export HOME=/spideroak
mkdir -p $HOME

function log () {
	printf '%s %s\n' $(date --utc +'%Y-%m-%dZ%T.%N') "$*"
}

if [[ ! -e /docker.sock ]]; then
	log 'Cannot find /docker.sock, is it not mapped?'
	exit 1
fi
CONTAINER_ID=$(grep -Eom 1 '[a-f0-9]{64}' /proc/self/cgroup)

function scurl () {
	printf 'GET %s HTTP/1.0\n\n' $1 | ncat -U /docker.sock | sed -r '1,/^\r?$/d'
}

function not_configured () {
	return [[ "$(SpiderOak --userinfo)" =~ "New User Setup$" ]]
}

if [[ not_configured ]]; then
	log 'no previous configuration found'
	if [[ -t 1 ]]; then
		log 'launching interactive setup'
		SpiderOak --setup=-
	else
		log 'taking configuration from stdin'
		cat > /config.json
		SpiderOak --setup=/config.json
		rm /config.json
	fi
	exit 0
fi

log 'resetting included folders'
SpiderOak --reset-selection >/dev/null
scurl  "/v1.21/containers/$CONTAINER_ID/json" \
	| jq -r '.Mounts|map(.Destination)-["/docker.sock","/spideroak"]|join("\n")' \
	| while read f; do
		log "  include folder: $f"
		SpiderOak --include-dir="$f" >/dev/null
	done
log 'starting backup/sync'
SpiderOak --headless
