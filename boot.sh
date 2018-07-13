#!/bin/bash

sunxi-fel -p uboot u-boot-sunxi-with-spl.bin \
          write 0x43300000 rootfs.cpio.uboot \
          write 0x43000000 sun5i-r8-chip.dtb \
          write 0x43100000 u-boot.env \
          write 0x42000000 zImage
#sunxi-fel exec 0x4a000000
