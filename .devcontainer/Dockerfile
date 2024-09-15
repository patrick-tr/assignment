FROM docker:dind
USER root

# Change this with your dependencies, note that this uses alpine apk
RUN apk add git bash curl make vim go

RUN apk add git bash curl make vim go 
COPY deps /deps

RUN chmod +x /deps/* && mkdir -p /var/run/ /tmp/user/0

ENV PATH=$PATH:/deps
ENV DOCKER_HOST=unix:///var/run/docker.sock