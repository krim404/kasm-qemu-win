#!/bin/bash
/usr/bin/desktop_ready
cd /storage
if [ -e overlay.qcow2 ]; then
	rm overlay.qcow2
fi
if mountpoint -q /home/kasm-user; then
	echo "Starting in persistent mode"
else 
	if [ -e data.img ]; then
		echo "Creating Overlay and starting in overlay mode"
		qemu-img create -f qcow2 -b data.img -F raw overlay.qcow2
		export DISK_NAME=overlay
	else
		echo "Original Image not found, cant create overlay, starting in persistent mode"
	fi
fi
sleep 15
/usr/bin/xfce4-terminal -x /usr/bin/tini -s /run/entry.sh
