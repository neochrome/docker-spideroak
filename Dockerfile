# vim: ft=dockerfile
FROM centos:7
MAINTAINER Johan Stenqvist <johan@stenqvist.net>
LABEL Description="SpiderOAK client"

RUN \
	yum -y install nmap-ncat \
	&& curl -Ls 'https://spideroak.com/getbuild?platform=fedora&arch=x86_64' -o spideroak.rpm \
		&& rpm -i spideroak.rpm \
		&& rm -f spideroak.rpm \
	&& curl -Ls https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /bin/jq \
		&& chmod +x /bin/jq

COPY ./run.sh .
ENTRYPOINT ["./run.sh"]
CMD ["--headless"]
