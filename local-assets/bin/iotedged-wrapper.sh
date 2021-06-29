#!/usr/bin/env bash

set -Eeuo pipefail

wait_for_dockerd() {
	# wait till dockerd starts, max wait 10 seconds!
	local counter=0
	while [ ! -e /run/docker.sock ] && [ ${counter} -lt 10 ];
	do
		echo "Waiting for dockerd to start"
		sleep 1
		let counter=counter+1
	done
}

update_connection_string() {
	local cs=$(snapctl get connection-string)
	if [ -n "${cs}" ]; then
		${SNAP}/bin/yq eval -i \
			".provisioning.device_connection_string = \"$cs\"" \
			${SNAP_DATA}/etc/iotedge/config.yaml

		# unset string from snap config
		snapctl unset connection-string
	fi
}

update_host_name() {
	# update device host name in iotedge config.yaml
        ${SNAP}/bin/yq eval -i \
                ".hostname = \"$HOSTNAME\"" \
                ${SNAP_DATA}/etc/iotedge/config.yaml
}

# update config if needed
update_host_name
update_connection_string
# wait for dockerd
wait_for_dockerd

exec "$@" \
    -c /etc/iotedge/config.yaml
