#!/bin/sh
: > /dev/watchdog

. /lib/dracut-lib.sh

export PATH=/usr/sbin:/usr/bin:/sbin:/bin
command -v plymouth > /dev/null 2>&1 && plymouth --quit
exec > /dev/console 2>&1

echo "dracut-root-block-success" | dd oflag=direct,dsync of=/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_marker

if grep -qF ' rd.live.overlay=LABEL=persist ' /proc/cmdline; then
    # Writing to a file in the root filesystem lets test_run() verify that the autooverlay module successfully created
    # and formatted the overlay partition and that the dmsquash-live module used it when setting up the rootfs overlay.
    echo "dracut-autooverlay-success" > /overlay-marker
fi

export TERM=linux
export PS1='initramfs-test:\w\$ '
[ -f /etc/mtab ] || ln -sfn /proc/mounts /etc/mtab
[ -f /etc/fstab ] || ln -sfn /proc/mounts /etc/fstab
stty sane
echo "made it to the rootfs!"
if getargbool 0 rd.shell; then
    strstr "$(setsid --help)" "control" && CTTY="-c"
    setsid $CTTY sh -i
fi
echo "Powering down."
mount -n -o remount,ro /

poweroff -f
