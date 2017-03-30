FROM alpine:latest

MAINTAINER Andrew A. Smith <andy@tinnedfruit.org>

RUN apk add --update sysstat nmap-ncat && rm -rf /var/cache/apk/*

ADD cpu-agent.awk server.sh /

CMD ["/server.sh"]
