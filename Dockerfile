FROM golang:1.17.0-alpine3.13

RUN apk add --update \
    git \
    py-pygments \
    sudo \
    nodejs \
    nodejs-npm \
    && npm install npm@latest -g \
    && rm -rf /var/cache/apk/* \
    && adduser -h /ghostbin -u 10000 -D -g "" ghostbin
USER ghostbin
ENV GOPATH=/ghostbin/go

RUN mkdir -p /ghostbin/go/src/github.com/DHowett \
    && git clone https://github.com/gvkazare/spectre.git /ghostbin/go/src/github.com/DHowett/ghostbin \
    && cd /ghostbin/go/src/github.com/DHowett/ghostbin \
    && git checkout v1-stable \
# Change pygmentize path
    && sed -i -e 's:./bin/pygments/pygmentize:/usr/bin/pygmentize:g' languages.yml \
    && echo "Go get" \
    && go get \
    && echo "Go install" \
    && go install \
    && echo "Go build" \
    && go build \
    && npm install
WORKDIR /ghostbin/go/src/github.com/DHowett/ghostbin
USER root
RUN mkdir /logs \
    && chown -R ghostbin:ghostbin /logs \
    && mkdir /data \
    && chown -R ghostbin:ghostbin /data

EXPOSE 8619

VOLUME /logs
VOLUME /data

COPY ghostbin.sh /ghostbin/ghostbin.sh
# Ensure it's executable
RUN chmod +x /ghostbin/ghostbin.sh
ENTRYPOINT /ghostbin/ghostbin.sh
# CMD -addr="0.0.0.0:8619" -log_dir="/logs" -root="/data"
