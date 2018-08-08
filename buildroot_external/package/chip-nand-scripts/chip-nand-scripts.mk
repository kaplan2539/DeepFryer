################################################################################
#
# CHIP-nand-scripts
#
################################################################################

CHIP_NAND_SCRIPTS_VERSION = a4c72cc12271c1c331de75894c5d904f8642fb74
CHIP_NAND_SCRIPTS_REPO_NAME = CHIP-nand-scripts
CHIP_NAND_SCRIPTS_SITE = https://github.com/nextthingco/$(CHIP_NAND_SCRIPTS_REPO_NAME)
CHIP_NAND_SCRIPTS_SITE_METHOD = git
CHIP_NAND_SCRIPTS_DEPENDENCIES = mtd uboot-tools android-tools

define HOST_CHIP_NAND_SCRIPTS_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/mk_buildroot_images $(HOST_DIR)/usr/bin/mk_buildroot_images
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/mk_gadget_images $(HOST_DIR)/usr/bin/mk_gadget_images
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/mk_uboot_script $(HOST_DIR)/usr/bin/mk_uboot_script
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/mk_chip_image $(HOST_DIR)/usr/bin/mk_chip_image
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/chip_nand_scripts_common $(HOST_DIR)/usr/bin/chip_nand_scripts_common
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/flash.sh $(HOST_DIR)/usr/bin/flash.sh
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/gotofastboot.sh $(HOST_DIR)/usr/bin/gotofastboot.sh
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/gotofastboot.scr.bin $(HOST_DIR)/usr/bin/gotofastboot.scr.bin
	$(INSTALL) -D -m 0755 $(HOST_CHIP_NAND_SCRIPTS_DIR)/erasenand.scr.bin $(HOST_DIR)/usr/bin/erasenand.scr.bin

	$(INSTALL) -D -m 0644 $(HOST_CHIP_NAND_SCRIPTS_DIR)/nand_configs/Hynix-MLC.config $(HOST_DIR)/usr/bin/nand_configs/Hynix-MLC.config
	$(INSTALL) -D -m 0644 $(HOST_CHIP_NAND_SCRIPTS_DIR)/nand_configs/Toshiba-MLC.config $(HOST_DIR)/usr/bin/nand_configs/Toshiba-MLC.config
	$(INSTALL) -D -m 0644 $(HOST_CHIP_NAND_SCRIPTS_DIR)/nand_configs/Toshiba-SLC-4G-TC58NVG2S0H.config $(HOST_DIR)/usr/bin/nand_configs/Toshiba-SLC-4G-TC58NVG2S0H.config
endef

$(eval $(host-generic-package))
