#!/bin/bash

KERN="Image"
DTB="hi6220-hikey.dtb"

#scp leo.yan@hackbox2.linaro.org:/home/leo.yan/hikey960/android-dev/arch/arm64/boot/$KERN ./
#scp leo.yan@hackbox2.linaro.org:/home/leo.yan/hikey960/android-dev/arch/arm64/boot/dts/hisilicon/$DTB ./

echo "Kernel folder is: $KERNELDIR"
echo "           Image: $KERN"
echo "             DTB: $DTB"

if [ ! -f $KERN ]; then
	echo "$KERN is not found!"
	exit
fi

if [ ! -f $DTB ]; then
	echo "$DTB is not found!"
	exit
fi

WORKDIR=`pwd`

mkdir boot-fat
sudo mount -o loop,rw,sync boot-linux.uefi.img boot-fat

cat > "${WORKDIR}"/grub.cfg << EOL
set default="0"
set timeout=1

menuentry 'Custom Kernel (Debian 9)' {
    search.fs_label rootfs root
    search.fs_label boot esp
    linux (\$esp)/Image root=/dev/mmcblk0p9 rootwait rw efi=noruntime earlycon=pl011,0xf7113000 crashkernel=128M loglevel=8 ftrace_notrace=rcu*,*lock,*spin* coresight_cpu_debug.enable=1 slub_debug=FPZU crash_kexec_post_notifiers
    initrd /boot/initrd.img-4.15-hikey
    devicetree (\$esp)/hi6220-hikey.dtb
}

menuentry 'Debian GNU/Linux, with Linux 4.15-hikey' {
    search.fs_label rootfs root
    search.fs_label boot esp
    linux (\$esp)/Image root=/dev/disk/by-partlabel/system rootwait rw
    devicetree (\$esp)/hi6220-hikey.dtb
    initrd  /boot/initrd.img-4.15-hikey
}

menuentry 'Fastboot' {
    search.fs_label boot root
    chainloader (\$root)/EFI/BOOT/fastboot.efi
}
EOL

sudo cp -f "${WORKDIR}"/grubaa64.efi boot-fat/EFI/BOOT/ || true
sudo cp -f "${WORKDIR}"/grub.cfg boot-fat/EFI/BOOT/ || true
sudo cp -f $KERN $DTB boot-fat/ || true

sync
sudo umount boot-fat
rmdir boot-fat

echo "relay1 off" > /dev/ttyACM0; sleep 1; echo "relay1 on" > /dev/ttyACM0

echo "Press F in console...."
sleep 5
echo 'f' > /dev/ttyUSB2
sleep 1

sudo fastboot flash boot "${WORKDIR}"/boot-linux.uefi.img

sleep 2
echo "relay1 off" > /dev/ttyACM0; sleep 1; echo "relay1 on" > /dev/ttyACM0
