#!/bin/sh
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

if [[ ! -d "$HOME/.config/SpiderOakONE" ]]; then
	log 'no previous configuration found, launching setup'
	SpiderOak --setup=-
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
