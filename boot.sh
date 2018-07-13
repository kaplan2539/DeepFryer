#!/bin/bash

IMAGES=buildroot/output/images

sunxi-fel -p uboot $IMAGES/u-boot-sunxi-with-spl.bin \
          write 0x43300000 $IMAGES/rootfs.cpio.uboot \
          write 0x43000000 $IMAGES/sun5i-r8-chip.dtb \
          write 0x42000000 $IMAGES/zImage \
          write 0x43100000 buildroot_external/board/nextthing/chip/u-boot.env \
