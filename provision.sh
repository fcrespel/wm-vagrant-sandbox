#!/bin/bash

# Install Docker
if [ ! -e "/etc/yum.repos.d/docker-ce.repo" ]; then
    curl -sSL -o "/etc/yum.repos.d/docker-ce.repo" https://download.docker.com/linux/centos/docker-ce.repo
fi
if ! command -v docker >/dev/null 2>&1; then
    yum -y install containerd.io docker-ce docker-ce-cli docker-compose-plugin
fi
gpasswd -a vagrant docker
systemctl enable --now docker

# Create files
cat - > /home/vagrant/is.properties <<EOF
jms.DEFAULT_IS_JMS_CONNECTION.enabled=true
jms.DEFAULT_IS_JMS_CONNECTION.jndi_automaticallyCreateUMAdminObjects=true
jndi.DEFAULT_IS_JNDI_PROVIDER.providerURL=nsp://um:9000
EOF
cat - > /home/vagrant/docker-compose.yml <<EOF
services:
  init:
    image: busybox:latest
    command: "chown 1724:1724 /data"
    volumes:
      - is-data:/data
    profiles:
      - init
  is:
    image: softwareag/webmethods-microservicesruntime:10.15.0.8-ubi
    hostname: is
    ports:
      - "5543:5543"
      - "5555:5555"
    environment:
      - EXTERNALIZE_PACKAGES=true
      - HOST_DIR=/data
      - JAVA_MIN_MEM=1024M
      - JAVA_MAX_MEM=1024M
    volumes:
      - ./is.properties:/opt/softwareag/IntegrationServer/application.properties
      - is-data:/data
  um:
    image: softwareag/universalmessaging-server:10.15.0.9
    hostname: um
    ports:
      - "9000:9000"
    environment:
      - INIT_JAVA_MEM_SIZE=512
      - MAX_JAVA_MEM_SIZE=512
    volumes:
      - um-data:/opt/softwareag/UniversalMessaging/server/umserver/data
      - um-logs:/opt/softwareag/UniversalMessaging/server/umserver/logs
volumes:
  is-data:
  um-data:
  um-logs:
EOF
chown vagrant:vagrant /home/vagrant/*

# Start containers
pushd /home/vagrant >/dev/null
docker compose pull -q
docker compose run --rm init
docker compose up -d
popd >/dev/null
