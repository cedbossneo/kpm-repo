#!/bin/sh
echo "Installing config"
mkdir /rootfs/etc/ceph
echo "Installing ceph-tools"
checksum()
{
	md5sum $1 | awk '{print $1}'
}

for UTIL in ceph ceph-disk rados rbd; do

    if [ ! -e /rootfs/usr/bin/$UTIL ] || [ "$(checksum /rootfs/usr/bin/$UTIL)" != "$(checksum /$UTIL)" ]; then
    	echo "Installing $UTIL to /usr/bin"
    	cp -pf /$UTIL /rootfs/usr/bin
    fi

done
while true
do
	cp -f /conf/* /rootfs/etc/ceph/
	cp -f /etc/resolv.conf /rootfs/etc/ceph/
	sleep 60
done
