################################################################################
#
# uboot
#
################################################################################

CHIP_UBOOT_VERSION = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_VERSION))
CHIP_UBOOT_BOARD_NAME = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_BOARDNAME))

CHIP_UBOOT_LICENSE = GPL-2.0+
CHIP_UBOOT_LICENSE_FILES = Licenses/gpl-2.0.txt

CHIP_UBOOT_INSTALL_IMAGES = YES

CHIP_UBOOT_BINARIES_DIR = $(BINARIES_DIR)/CHIP-uboot

ifeq ($(CHIP_UBOOT_VERSION),custom)
# Handle custom U-Boot tarballs as specified by the configuration
CHIP_UBOOT_TARBALL = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_TARBALL_LOCATION))
CHIP_UBOOT_SITE = $(patsubst %/,%,$(dir $(CHIP_UBOOT_TARBALL)))
CHIP_UBOOT_SOURCE = $(notdir $(CHIP_UBOOT_TARBALL))
else ifeq ($(BR2_TARGET_CHIP_UBOOT_CUSTOM_GIT),y)
CHIP_UBOOT_SITE = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_REPO_URL))
CHIP_UBOOT_SITE_METHOD = git
else ifeq ($(BR2_TARGET_CHIP_UBOOT_CUSTOM_HG),y)
CHIP_UBOOT_SITE = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_REPO_URL))
CHIP_UBOOT_SITE_METHOD = hg
else ifeq ($(BR2_TARGET_CHIP_UBOOT_CUSTOM_SVN),y)
CHIP_UBOOT_SITE = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_REPO_URL))
CHIP_UBOOT_SITE_METHOD = svn
else
# Handle stable official U-Boot versions
CHIP_UBOOT_SITE = ftp://ftp.denx.de/pub/u-boot
CHIP_UBOOT_SOURCE = u-boot-$(CHIP_UBOOT_VERSION).tar.bz2
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT)$(BR2_TARGET_CHIP_UBOOT_LATEST_VERSION),y)
BR_NO_CHECK_HASH_FOR += $(CHIP_UBOOT_SOURCE)
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_BIN),y)
CHIP_UBOOT_BINS += u-boot.bin
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_ELF),y)
CHIP_UBOOT_BINS += u-boot
# To make elf usable for debuging on ARC use special target
ifeq ($(BR2_arc),y)
CHIP_UBOOT_MAKE_TARGET += mdbtrick
endif
endif

# Call 'make all' unconditionally
CHIP_UBOOT_MAKE_TARGET += all

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_KWB),y)
CHIP_UBOOT_BINS += u-boot.kwb
CHIP_UBOOT_MAKE_TARGET += u-boot.kwb
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_AIS),y)
CHIP_UBOOT_BINS += u-boot.ais
CHIP_UBOOT_MAKE_TARGET += u-boot.ais
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_NAND_BIN),y)
CHIP_UBOOT_BINS += u-boot-nand.bin
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_DTB_IMG),y)
CHIP_UBOOT_BINS += u-boot-dtb.img
CHIP_UBOOT_MAKE_TARGET += u-boot-dtb.img
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_DTB_BIN),y)
CHIP_UBOOT_BINS += u-boot-dtb.bin
CHIP_UBOOT_MAKE_TARGET += u-boot-dtb.bin
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_IMG),y)
CHIP_UBOOT_BINS += u-boot.img
CHIP_UBOOT_MAKE_TARGET += u-boot.img
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_IMX),y)
CHIP_UBOOT_BINS += u-boot.imx
CHIP_UBOOT_MAKE_TARGET += u-boot.imx
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_SB),y)
CHIP_UBOOT_BINS += u-boot.sb
CHIP_UBOOT_MAKE_TARGET += u-boot.sb
# mxsimage needs OpenSSL
CHIP_UBOOT_DEPENDENCIES += host-elftosb host-openssl
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_SD),y)
# BootStream (.sb) is generated by U-Boot, we convert it to SD format
CHIP_UBOOT_BINS += u-boot.sd
CHIP_UBOOT_MAKE_TARGET += u-boot.sb
CHIP_UBOOT_DEPENDENCIES += host-elftosb host-openssl
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_NAND),y)
CHIP_UBOOT_BINS += u-boot.nand
CHIP_UBOOT_MAKE_TARGET += u-boot.sb
CHIP_UBOOT_DEPENDENCIES += host-elftosb host-openssl
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_FORMAT_CUSTOM),y)
CHIP_UBOOT_BINS += $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_FORMAT_CUSTOM_NAME))
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_OMAP_IFT),y)
CHIP_UBOOT_BINS += u-boot.bin
CHIP_UBOOT_BIN_IFT = u-boot.bin.ift
endif

# The kernel calls AArch64 'arm64', but U-Boot calls it just 'arm', so
# we have to special case it. Similar for i386/x86_64 -> x86
ifeq ($(KERNEL_ARCH),arm64)
CHIP_UBOOT_ARCH = arm
else ifneq ($(filter $(KERNEL_ARCH),i386 x86_64),)
CHIP_UBOOT_ARCH = x86
else
CHIP_UBOOT_ARCH = $(KERNEL_ARCH)
endif

CHIP_UBOOT_MAKE_OPTS += \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	ARCH=$(CHIP_UBOOT_ARCH) \
	HOSTCC="$(HOSTCC) $(subst -I/,-isystem /,$(subst -I /,-isystem /,$(HOST_CFLAGS)))" \
	HOSTLDFLAGS="$(HOST_LDFLAGS)"

ifeq ($(BR2_TARGET_CHIP_UBOOT_NEEDS_ATF_BL31),y)
CHIP_UBOOT_DEPENDENCIES += arm-trusted-firmware
CHIP_UBOOT_MAKE_OPTS += BL31=$(CHIP_UBOOT_BINARIES_DIR)/bl31.bin
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_NEEDS_DTC),y)
CHIP_UBOOT_DEPENDENCIES += host-dtc
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_NEEDS_PYLIBFDT),y)
CHIP_UBOOT_DEPENDENCIES += host-python host-swig
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_NEEDS_OPENSSL),y)
CHIP_UBOOT_DEPENDENCIES += host-openssl
endif

# prior to u-boot 2013.10 the license info was in COPYING. Copy it so
# legal-info finds it
define CHIP_UBOOT_COPY_OLD_LICENSE_FILE
	if [ -f $(@D)/COPYING ]; then \
		$(INSTALL) -m 0644 -D $(@D)/COPYING $(@D)/Licenses/gpl-2.0.txt; \
	fi
endef

CHIP_UBOOT_POST_EXTRACT_HOOKS += CHIP_UBOOT_COPY_OLD_LICENSE_FILE
CHIP_UBOOT_POST_RSYNC_HOOKS += CHIP_UBOOT_COPY_OLD_LICENSE_FILE

ifneq ($(ARCH_XTENSA_OVERLAY_FILE),)
define CHIP_UBOOT_XTENSA_OVERLAY_EXTRACT
	$(call arch-xtensa-overlay-extract,$(@D),u-boot)
endef
CHIP_UBOOT_POST_EXTRACT_HOOKS += CHIP_UBOOT_XTENSA_OVERLAY_EXTRACT
CHIP_UBOOT_EXTRA_DOWNLOADS += $(ARCH_XTENSA_OVERLAY_URL)
endif

# Analogous code exists in linux/linux.mk. Basically, the generic
# package infrastructure handles downloading and applying remote
# patches. Local patches are handled depending on whether they are
# directories or files.
CHIP_UBOOT_PATCHES = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_PATCH))
CHIP_UBOOT_PATCH = $(filter ftp://% http://% https://%,$(CHIP_UBOOT_PATCHES))

define CHIP_UBOOT_APPLY_LOCAL_PATCHES
	for p in $(filter-out ftp://% http://% https://%,$(CHIP_UBOOT_PATCHES)) ; do \
		if test -d $$p ; then \
			$(APPLY_PATCHES) $(@D) $$p \*.patch || exit 1 ; \
		else \
			$(APPLY_PATCHES) $(@D) `dirname $$p` `basename $$p` || exit 1; \
		fi \
	done
endef
CHIP_UBOOT_POST_PATCH_HOOKS += CHIP_UBOOT_APPLY_LOCAL_PATCHES

# This is equivalent to upstream commit
# http://git.denx.de/?p=u-boot.git;a=commitdiff;h=e0d20dc1521e74b82dbd69be53a048847798a90a. It
# fixes a build failure when libfdt-devel is installed system-wide.
# This only works when scripts/dtc/libfdt exists (E.G. versions containing
# http://git.denx.de/?p=u-boot.git;a=commitdiff;h=c0e032e0090d6541549b19cc47e06ccd1f302893)
define CHIP_UBOOT_FIXUP_LIBFDT_INCLUDE
	if [ -d $(@D)/scripts/dtc/libfdt ]; then \
		$(SED) 's%-I$$(srctree)/lib/libfdt%-I$$(srctree)/scripts/dtc/libfdt%' $(@D)/tools/Makefile; \
	fi
endef
CHIP_UBOOT_POST_PATCH_HOOKS += CHIP_UBOOT_FIXUP_LIBFDT_INCLUDE

ifeq ($(BR2_TARGET_CHIP_UBOOT_USE_DEFCONFIG),y)
CHIP_UBOOT_KCONFIG_DEFCONFIG = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_BOARD_DEFCONFIG))_defconfig
else ifeq ($(BR2_TARGET_CHIP_UBOOT_USE_CUSTOM_CONFIG),y)
CHIP_UBOOT_KCONFIG_FILE = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_CONFIG_FILE))
endif # BR2_TARGET_CHIP_UBOOT_USE_DEFCONFIG

CHIP_UBOOT_KCONFIG_FRAGMENT_FILES = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CONFIG_FRAGMENT_FILES))
CHIP_UBOOT_KCONFIG_EDITORS = menuconfig xconfig gconfig nconfig
CHIP_UBOOT_KCONFIG_OPTS = $(CHIP_UBOOT_MAKE_OPTS)
define CHIP_UBOOT_HELP_CMDS
	@echo '  uboot-menuconfig       - Run U-Boot menuconfig'
	@echo '  uboot-savedefconfig    - Run U-Boot savedefconfig'
	@echo '  uboot-update-defconfig - Save the U-Boot configuration to the path specified'
	@echo '                             by BR2_TARGET_CHIP_UBOOT_CUSTOM_CONFIG_FILE'
endef

CHIP_UBOOT_CUSTOM_DTS_PATH = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_DTS_PATH))

define CHIP_UBOOT_BUILD_CMDS
	$(if $(CHIP_UBOOT_CUSTOM_DTS_PATH),
		cp -f $(CHIP_UBOOT_CUSTOM_DTS_PATH) $(@D)/arch/$(CHIP_UBOOT_ARCH)/dts/
	)
	$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) -C $(@D) $(CHIP_UBOOT_MAKE_OPTS) \
		$(CHIP_UBOOT_MAKE_TARGET)
	$(if $(BR2_TARGET_CHIP_UBOOT_FORMAT_SD),
		$(@D)/tools/mxsboot sd $(@D)/u-boot.sb $(@D)/u-boot.sd)
	$(if $(BR2_TARGET_CHIP_UBOOT_FORMAT_NAND),
		$(@D)/tools/mxsboot \
			-w $(BR2_TARGET_CHIP_UBOOT_FORMAT_NAND_PAGE_SIZE) \
			-o $(BR2_TARGET_CHIP_UBOOT_FORMAT_NAND_OOB_SIZE) \
			-e $(BR2_TARGET_CHIP_UBOOT_FORMAT_NAND_ERASE_SIZE) \
			nand $(@D)/u-boot.sb $(@D)/u-boot.nand)
endef

define CHIP_UBOOT_BUILD_OMAP_IFT
	$(HOST_DIR)/bin/gpsign -f $(@D)/u-boot.bin \
		-c $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_OMAP_IFT_CONFIG))
endef

ifneq ($(BR2_TARGET_CHIP_UBOOT_ENVIMAGE),)
define CHIP_UBOOT_GENERATE_ENV_IMAGE
	cat $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_ENVIMAGE_SOURCE)) \
		>$(@D)/buildroot-env.txt
	$(HOST_DIR)/bin/mkenvimage -s $(BR2_TARGET_CHIP_UBOOT_ENVIMAGE_SIZE) \
		$(if $(BR2_TARGET_CHIP_UBOOT_ENVIMAGE_REDUNDANT),-r) \
		$(if $(filter BIG,$(BR2_ENDIAN)),-b) \
		-o $(CHIP_UBOOT_BINARIES_DIR)/uboot-env.bin \
		$(@D)/buildroot-env.txt
endef
endif

define CHIP_UBOOT_INSTALL_IMAGES_CMDS
    mkdir -p $(CHIP_UBOOT_BINARIES_DIR)
	$(foreach f,$(CHIP_UBOOT_BINS), \
			cp -dpf $(@D)/$(f) $(CHIP_UBOOT_BINARIES_DIR)/
	)
	$(if $(BR2_TARGET_CHIP_UBOOT_FORMAT_NAND),
		cp -dpf $(@D)/u-boot.sb $(CHIP_UBOOT_BINARIES_DIR))
	$(if $(BR2_TARGET_CHIP_UBOOT_SPL),
		$(foreach f,$(call qstrip,$(BR2_TARGET_CHIP_UBOOT_SPL_NAME)), \
			cp -dpf $(@D)/$(f) $(CHIP_UBOOT_BINARIES_DIR)/
		)
	)
	$(CHIP_UBOOT_GENERATE_ENV_IMAGE)
	$(if $(BR2_TARGET_CHIP_UBOOT_BOOT_SCRIPT),
		$(HOST_DIR)/bin/mkimage -C none -A $(MKIMAGE_ARCH) -T script \
			-d $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_BOOT_SCRIPT_SOURCE)) \
			$(CHIP_UBOOT_BINARIES_DIR)/boot.scr)
endef

define CHIP_UBOOT_INSTALL_OMAP_IFT_IMAGE
	cp -dpf $(@D)/$(CHIP_UBOOT_BIN_IFT) $(CHIP_UBOOT_BINARIES_DIR)/
endef

ifeq ($(BR2_TARGET_CHIP_UBOOT_OMAP_IFT),y)
ifeq ($(BR_BUILDING),y)
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_OMAP_IFT_CONFIG)),)
$(error No gpsign config file. Check your BR2_TARGET_CHIP_UBOOT_OMAP_IFT_CONFIG setting)
endif
ifeq ($(wildcard $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_OMAP_IFT_CONFIG))),)
$(error gpsign config file $(BR2_TARGET_CHIP_UBOOT_OMAP_IFT_CONFIG) not found. Check your BR2_TARGET_CHIP_UBOOT_OMAP_IFT_CONFIG setting)
endif
endif
CHIP_UBOOT_DEPENDENCIES += host-omap-u-boot-utils
CHIP_UBOOT_POST_BUILD_HOOKS += CHIP_UBOOT_BUILD_OMAP_IFT
CHIP_UBOOT_POST_INSTALL_IMAGES_HOOKS += CHIP_UBOOT_INSTALL_OMAP_IFT_IMAGE
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_ZYNQ_IMAGE),y)
define CHIP_UBOOT_GENERATE_ZYNQ_IMAGE
	$(HOST_DIR)/bin/python2 \
		$(HOST_DIR)/bin/zynq-boot-bin.py \
		-u $(@D)/$(firstword $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_SPL_NAME))) \
		-o $(CHIP_UBOOT_BINARIES_DIR)/BOOT.BIN
endef
CHIP_UBOOT_DEPENDENCIES += host-zynq-boot-bin
CHIP_UBOOT_POST_INSTALL_IMAGES_HOOKS += CHIP_UBOOT_GENERATE_ZYNQ_IMAGE
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_ALTERA_SOCFPGA_IMAGE_CRC),y)
ifeq ($(BR2_TARGET_CHIP_UBOOT_SPL),y)
CHIP_UBOOT_CRC_ALTERA_SOCFPGA_INPUT_IMAGES = $(call qstrip,$(BR2_TARGET_CHIP_UBOOT_SPL_NAME))
CHIP_UBOOT_CRC_ALTERA_SOCFPGA_HEADER_VERSION = 0
else
CHIP_UBOOT_CRC_ALTERA_SOCFPGA_INPUT_IMAGES = u-boot-dtb.bin
CHIP_UBOOT_CRC_ALTERA_SOCFPGA_HEADER_VERSION = 1
endif
define CHIP_UBOOT_CRC_ALTERA_SOCFPGA_IMAGE
	$(foreach f,$(CHIP_UBOOT_CRC_ALTERA_SOCFPGA_INPUT_IMAGES), \
		$(HOST_DIR)/bin/mkpimage \
			-v $(CHIP_UBOOT_CRC_ALTERA_SOCFPGA_HEADER_VERSION) \
			-o $(CHIP_UBOOT_BINARIES_DIR)/$(notdir $(call qstrip,$(f))).crc \
			$(@D)/$(call qstrip,$(f))
	)
endef
CHIP_UBOOT_DEPENDENCIES += host-mkpimage
CHIP_UBOOT_POST_INSTALL_IMAGES_HOOKS += CHIP_UBOOT_CRC_ALTERA_SOCFPGA_IMAGE
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_ENVIMAGE),y)
ifeq ($(BR_BUILDING),y)
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_ENVIMAGE_SOURCE)),)
$(error Please define a source file for Uboot environment (BR2_TARGET_CHIP_UBOOT_ENVIMAGE_SOURCE setting))
endif
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_ENVIMAGE_SIZE)),)
$(error Please provide Uboot environment size (BR2_TARGET_CHIP_UBOOT_ENVIMAGE_SIZE setting))
endif
endif
CHIP_UBOOT_DEPENDENCIES += host-uboot-tools
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT_BOOT_SCRIPT),y)
ifeq ($(BR_BUILDING),y)
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_BOOT_SCRIPT_SOURCE)),)
$(error Please define a source file for Uboot boot script (BR2_TARGET_CHIP_UBOOT_BOOT_SCRIPT_SOURCE setting))
endif
endif
CHIP_UBOOT_DEPENDENCIES += host-uboot-tools
endif

ifeq ($(BR2_TARGET_CHIP_UBOOT)$(BR_BUILDING),yy)

#
# Check U-Boot  the defconfig/custom config file options (for kconfig) #
ifeq ($(BR2_TARGET_CHIP_UBOOT_USE_DEFCONFIG),y)
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_BOARD_DEFCONFIG)),)
$(error No board defconfig name specified, check your BR2_TARGET_CHIP_UBOOT_BOARD_DEFCONFIG setting)
endif # qstrip BR2_TARGET_CHIP_UBOOT_BOARD_DEFCONFIG
endif # BR2_TARGET_CHIP_UBOOT_USE_DEFCONFIG
ifeq ($(BR2_TARGET_CHIP_UBOOT_USE_CUSTOM_CONFIG),y)
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_CONFIG_FILE)),)
$(error No board configuration file specified, check your BR2_TARGET_CHIP_UBOOT_CUSTOM_CONFIG_FILE setting)
endif # qstrip BR2_TARGET_CHIP_UBOOT_CUSTOM_CONFIG_FILE
endif # BR2_TARGET_CHIP_UBOOT_USE_CUSTOM_CONFIG

#
# Check custom version option
#
ifeq ($(BR2_TARGET_CHIP_UBOOT_CUSTOM_VERSION),y)
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_VERSION_VALUE)),)
$(error No custom U-Boot version specified. Check your BR2_TARGET_CHIP_UBOOT_CUSTOM_VERSION_VALUE setting)
endif # qstrip BR2_TARGET_CHIP_UBOOT_CUSTOM_VERSION_VALUE
endif # BR2_TARGET_CHIP_UBOOT_CUSTOM_VERSION

#
# Check custom tarball option
#
ifeq ($(BR2_TARGET_CHIP_UBOOT_CUSTOM_TARBALL),y)
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_TARBALL_LOCATION)),)
$(error No custom U-Boot tarball specified. Check your BR2_TARGET_CHIP_UBOOT_CUSTOM_TARBALL_LOCATION setting)
endif # qstrip BR2_TARGET_CHIP_UBOOT_CUSTOM_TARBALL_LOCATION
endif # BR2_TARGET_CHIP_UBOOT_CUSTOM_TARBALL

#
# Check Git/Mercurial repo options
#
ifeq ($(BR2_TARGET_CHIP_UBOOT_CUSTOM_GIT)$(BR2_TARGET_CHIP_UBOOT_CUSTOM_HG),y)
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_REPO_URL)),)
$(error No custom U-Boot repository URL specified. Check your BR2_TARGET_CHIP_UBOOT_CUSTOM_REPO_URL setting)
endif # qstrip BR2_TARGET_CHIP_UBOOT_CUSTOM_CUSTOM_REPO_URL
ifeq ($(call qstrip,$(BR2_TARGET_CHIP_UBOOT_CUSTOM_REPO_VERSION)),)
$(error No custom U-Boot repository URL specified. Check your BR2_TARGET_CHIP_UBOOT_CUSTOM_REPO_VERSION setting)
endif # qstrip BR2_TARGET_CHIP_UBOOT_CUSTOM_CUSTOM_REPO_VERSION
endif # BR2_TARGET_CHIP_UBOOT_CUSTOM_GIT || BR2_TARGET_CHIP_UBOOT_CUSTOM_HG

endif # BR2_TARGET_CHIP_UBOOT && BR_BUILDING

$(eval $(kconfig-package))
