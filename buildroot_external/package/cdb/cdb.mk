################################################################################
#
# CHIP debugging bridge (CDB)
#
################################################################################

CDB_SITE = https://github.com/nextthingco/cdb
CDB_SITE_METHOD = git
CDB_GIT_BRANCH = unstable
CDB_GIT_COMMIT = $(shell git ls-remote $(CDB_SITE) $(CDB_GIT_BRANCH) | cut -f1)
CDB_VERSION = $(CDB_GIT_BRANCH)

CDB_DEPENDENCIES = host-go

ifeq ($(BR2_arm),y)
CDB_GOARCH=arm
endif

ifeq ($(BR2_aarch64),y)
CDB_GOARCH=arm64
endif

CDB_ARTIFACT_DIR=$(@D)/build/linux_$(CDB_GOARCH)/cdbd

CDB_GOPATH = "$(@D)/gopath"
CDB_MAKE_ENV = $(HOST_GO_TARGET_ENV) \
	GOBIN="$(@D)/bin" \
	GOPATH="$(CDB_GOPATH)"\
	GOARCH="$(CDB_GOARCH)"\
	GIT_COMMIT="$(CDB_GIT_COMMIT)"\
	GIT_BRANCH="$(CDB_GIT_BRANCH)"\
	$(TARGET_MAKE_ENV)

define CDB_BUILD_CMDS
		echo "CDB_GIT_BRANCH=$(CDB_GIT_BRANCH)"
		echo "CDB_GIT_COMMIT=$(CDB_GIT_COMMIT)"
        $(MAKE) clean
#        $(CDB_MAKE_ENV) $(MAKE) -C $(@D) get
        $(CDB_MAKE_ENV) $(MAKE) -C $(@D) cdbd
endef

define CDB_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(CDB_ARTIFACT_DIR) $(TARGET_DIR)/usr/bin/cdbd
	$(INSTALL) -D -m 0755 $(CDB_PKGDIR)/S81_cdbd $(TARGET_DIR)/etc/init.d/
endef

$(eval $(generic-package))
