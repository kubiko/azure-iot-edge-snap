#!/usr/bin/env bash
set -Eeuo pipefail

# update device host name in iotedge config.yaml
sed -i -e \
	's/hostname: .*/hostname: \"'"${HOSTNAME}"'\"/g' \
	${SNAP_DATA}/etc/iotedge/config.yaml


# wait till dockerd starts
while [ ! -e /run/docker.sock ];
do
	echo "Waiting for dockerd to start"
	sleep 1
done
exec "$@" \
    -c ${SNAP_DATA}/etc/iotedge/config.yaml
