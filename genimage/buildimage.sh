#!/bin/bash
# NOTE: this file used in docker container
#       don't execute it directly
#                               -- xiaofan

set -xe

# now we are in /work
# /work/rootfs.tar mounted from host (read only)
# /work/genimage mounted from host (read only)
# /work/output mounted from host (read/write)
# /work/input is temporary directory, store genimage input files
# /work/rootfs is temporary directory, store all files in rootfs partition
# /work/boot is temporary directory, store all files in boot partition

mkdir rootfs
tar -C rootfs -xf rootfs.tar

mv rootfs/boot .
mkdir rootfs/boot

rm rootfs/.dockerenv
rm rootfs/etc/resolv.conf
echo "openeuler-d1" >rootfs/etc/hostname
cat >rootfs/etc/fstab <<EOF
/dev/mmcblk0p5      /           ext4    rw  0   1
/dev/mmcblk0p4      /boot       vfat    rw  0   2
EOF
tar hxvf genimage/lib_modules.tar.gz -C rootfs/

# generate image
mkdir input
genimage --config genimage/image.cfg --rootpath rootfs --input genimage
rm -rf tmp/

# copy to host
chown -R $HOSTUID:$HOSTGID images/
cp -a images/* output/
