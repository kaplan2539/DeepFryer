#!/bin/bash

# Environment variables passed in from buildroot:
# BR2_CONFIG, HOST_DIR, STAGING_DIR, TARGET_DIR, BUILD_DIR, BINARIES_DIR and BASE_DIR.

echo "##############################################################################"
echo "## $0 "
echo "##############################################################################"

echo "# \$1 = $1"
echo "# \$2 = $2"

IFS=", " read -r -a EXTRA_ARGS <<< "$2"

echo "# BR2_CONFIG=$BR2_CONFIG"
echo "# HOST_DIR=$HOST_DIR"
echo "# STAGING_DIR=$STAGING_DIR"
echo "# TARGET_DIR=$TARGET_DIR"
echo "# BUILD_DIR=$BUILD_DIR"
echo "# BINARIES_DIR=$BINARIES_DIR"
echo "# BASE_DIR=$BASE_DIR"

ROOT_DIR="${BR2_EXTERNAL_GADGETOS_PATH}"

## create NAND images
pushd $BINARIES_DIR/CHIP-uboot

echo "## creating SPL image"
"${HOST_DIR}/usr/bin/mk_chip_image" hynix-mlc spl sunxi-spl.bin spl-hynix-mlc.bin
"${HOST_DIR}/usr/bin/mk_chip_image" toshiba-mlc spl sunxi-spl.bin spl-toshiba-mlc.bin

echo "## creating uboot image"
"${HOST_DIR}/usr/bin/mk_chip_image" hynix-mlc u-boot u-boot-dtb.bin u-boot-hynix-mlc.bin
"${HOST_DIR}/usr/bin/mk_chip_image" toshiba-mlc u-boot u-boot-dtb.bin u-boot-toshiba-mlc.bin

popd
