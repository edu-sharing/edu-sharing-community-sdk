#!/bin/bash

set -e
set -o pipefail

if [[ ! -d "$1" ]] ; then
  echo "ERROR Path not found: $1"
  exit 1
fi

cd "$1"

delete_folder() {
  if [[ -d "$1" ]] ; then
    echo "delete $1"
    rm -rf "$1"
  elif [[ -f "$1" ]] ; then
    echo "delete $1"
    rm -f "$1"
  fi
}

delete_folder deploy/docker/build/activemq
delete_folder deploy/docker/build/apache_exporter
delete_folder deploy/docker/build/mailcatcher
delete_folder deploy/docker/build/minideb
delete_folder deploy/docker/build/postgresql
delete_folder deploy/docker/build/postgresql_exporter
delete_folder deploy/docker/build/redis
delete_folder deploy/docker/build/rediscluster
delete_folder deploy/docker/build/redis_exporter
delete_folder deploy/docker/build/varnish
delete_folder deploy/docker/build/varnish_exporter

delete_folder deploy/docker/compose/src/main/compose/0_edusharing-remote.yml
delete_folder deploy/docker/repository
delete_folder deploy/docker/services
