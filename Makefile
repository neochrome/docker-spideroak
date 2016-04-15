build:
	@docker build -t dev/spideroak -f Dockerfile .
	@docker build -t dev/spideroak-settings -f Dockerfile.settings .
	@docker build -t dev/spideroak-archive -f Dockerfile.archive .

volumes:
	@docker create --name spideroak-settings dev/spideroak-settings 2>/dev/null || true
	@docker create --name spideroak-archive dev/spideroak-archive 2>/dev/null || true

start: remove build volumes
	@docker run -it --name spideroak \
		-v /var/run/docker.sock:/docker.sock:ro \
		--volumes-from spideroak-settings \
		--volumes-from spideroak-archive \
		dev/spideroak

stop:
	@docker kill spideroak 1>&2 || true

remove: stop
	@docker rm spideroak 1>&2 || true

clean: remove
	@docker rmi dev/spideroak || true
	@docker rm spideroak-settings || true
	@docker rmi dev/spideroak-settings || true
	@docker rm spideroak-archive || true
	@docker rmi dev/spideroak-archive || true

debug: remove build volumes
	@docker run -it --name spideroak \
		-v /var/run/docker.sock:/docker.sock:ro \
		-v $$PWD/run.sh:/run.sh \
		--volumes-from spideroak-settings \
		--volumes-from spideroak-archive \
		--entrypoint /bin/sh \
		dev/spideroak
