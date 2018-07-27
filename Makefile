export OUTPUT_DIR=$(PWD)/buildroot/output
export BR_DIR=$(PWD)/buildroot
export BR2_EXTERNAL=$(PWD)/buildroot_external

%_defconfig:
	@$(DOCKER) make -C $(BR_DIR) O=$(OUTPUT_DIR) $@

%:
	@$(DOCKER) make -C $(BR_DIR) O=$(OUTPUT_DIR) $@

nconfig:
	@$(DOCKER) make -C $(BR_DIR) O=$(OUTPUT_DIR) nconfig
