## Purpose

This repo is used to build boot image for Hikey620 board.

## Steps

# Clone Hikey mainline kernel code base

  Linux mainline kernel has merged almost components for Hikey620, but
  it misses HDMI/display related drivers.  For general development, you
  could directly use mainline kernel; for audio/video related
  development, please use John's branch for kernel building:

  git clone https://git.linaro.org/people/john.stultz/android-dev.git
  cd android-dev
  git checkout -b hikey-mainline-WIP origin/dev/hikey-mainline-WIP

# Build Image and dtb

  Please use the config file in this repository
  'config_dbg_audio_dmabuf' so that can enable audio/video related
  components:

  cp config_dbg_audio_dmabuf android-dev/.config
  make oldconfig
  make -j8 Image dtbs

# Generate boot.img and flash it on the board

  cp android-dev/arch/arm64/boot/Image ./
  cp android-dev/arch/arm64/boot/dts/hisilicon/hi6220-hikey.dtb ./

  sh flash-boot.sh

  In the shell script 'flash-boot.sh', it uses a relay5 to reboot the
  Hikey board and it will send character 'f' to the console so this
  can make the UEFI entering into fastboot mode; then it use fastboot
  command to flash boot.img.  These steps can be finished by manually
  execution commands on PC.
