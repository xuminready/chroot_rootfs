#!/bin/bash
set -e

echo "collected from Internet by XuMinReady@Gmail.com"
echo "https://github.com/xuminready/Embedded-Linux-Dev-notes"$'\n'

if [ $(whoami) != 'root' ]; then
	echo $'\n'"!!!!This script must be run as root!!!!"$'\n'
	exit 1
fi

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'if [ $? -ne 0 ]; then echo "$0 : \"${last_command}\" command filed with exit code $?." && cleanup; else echo "$0 complete!!"; fi' EXIT

echo "if you want to chroot to a foreign filesystem, install qemu-user-static. For Ubuntu/Debian, you can use:  apt-get install qemu qemu-user-static binfmt-support"$'\n'

rootfs_img=$1
arch=$2

if [ -z "$rootfs_img" ]; then
	echo $'\n'usage: $0 rootfs_path/*.img [arm, aarch64, ...] $'\n'
	exit 1
fi

# delete file if exist
delete_if_exist() {
	FILE=$1
	if [[ -e "$FILE" ]]; then
		echo "rm -rf $FILE"
		rm -rf $FILE
	fi
}

umount_if_exist() {
	DIR=$1
	if [[ -d "$DIR" ]]; then
		echo "umount $DIR"
		umount $DIR || true
	fi
}

cleanup() {
	echo Cleaning up
	delete_if_exist ${root_mnt}/usr/sbin/policy-rc.d
	delete_if_exist ${root_mnt}/etc/resolv.conf
	delete_if_exist ${root_mnt}/qemu-$arch-static
	umount_if_exist ${root_mnt}/proc
	umount_if_exist ${root_mnt}/sys
	umount_if_exist ${root_mnt}/tmp
	umount_if_exist ${root_mnt}/dev/pts
	umount_if_exist ${root_mnt}/dev
	sync

	if [ x"${root_dev}" != x ]; then
		umount_if_exist ${root_mnt}
		losetup -d ${root_dev}
	fi
}

if [ ${rootfs_img##*.} = 'img' ]; then
	root_dev=$(losetup -Pf --show ${rootfs_img})
	lsblk $root_dev
	mkdir -p rootfs
	root_mnt=rootfs

	echo "${root_dev}p* <-- Enter the partition index where rootfs is located.  "
	read num
	mount ${root_dev}p$num rootfs
else
	root_mnt=$rootfs_img
fi

echo Bind mounting proc sys and pts in chroot
mount --bind /proc ${root_mnt}/proc
mount --bind /sys ${root_mnt}/sys
mount --bind /dev ${root_mnt}/dev
mount --bind /dev/pts ${root_mnt}/dev/pts

echo Mounting tmp in chroot
mount none -t tmpfs -o size=104857600 ${root_mnt}/tmp

if [ -n "$arch" ]; then
	echo Copying qemu-$arch-static
	cp $(which qemu-$arch-static) ${root_mnt}
fi

echo Creating resolv.conf
cat <<EOF >${root_mnt}/etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

echo Configuring chroot apt to not start/restart services
#https://wiki.debian.org/chroot
cat >${root_mnt}/usr/sbin/policy-rc.d <<EOF
#!/bin/sh
exit 101
EOF
chmod a+x ${root_mnt}/usr/sbin/policy-rc.d

# Assume ischroot works
# See: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=685034

echo Starting $arch chroot

chroot ${root_mnt}

cleanup
