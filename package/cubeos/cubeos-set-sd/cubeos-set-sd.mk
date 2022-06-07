###############################################
#
# cubeos-set-sd Command Binary
#
###############################################
CUBEOS_SET_SD_VERSION = $(call qstrip,$(BR2_CUBEOS_VERSION))
CUBEOS_SET_SD_LICENSE = Apache-2.0
CUBEOS_SET_SD_LICENSE_FILES = LICENSE
CUBEOS_SET_SD_REDISTRIBUTE = NO
CUBEOS_SET_SD_SITE = $(CUBEOS_SET_SD_PKGDIR).
CUBEOS_SET_SD_SITE_METHOD = local
CUBEOS_SET_SD_DEPENDENCIES = cubeos
# The path from the SET_SD module to the build artifact directory
CUBEOS_ARTIFACT_BUILD_PATH = build/$(CUBEOS_TARGET)/source

# Link the local Kubos modules
define CUBEOS_SET_SD_CONFIGURE_CMDS
	cd $(@D) && \
	cubeos link -a
endef

# Use the Kubos SDK to build the cubeos-set-sd application
define CUBEOS_SET_SD_BUILD_CMDS
	cd $(@D) && \
	PATH=$(PATH):/usr/bin/iobc_toolchain/usr/bin && \
	cubeos -t $(CUBEOS_TARGET) build
endef
# Install the application into the rootfs file system
define CUBEOS_SET_SD_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 0755 $(@D)/$(CUBEOS_ARTIFACT_BUILD_PATH)/cubeos-set-sd \
		$(TARGET_DIR)/usr/bin/cubeos-set-sd
endef

cubeos-set-sd-fullclean: cubeos-set-sd-clean-for-reconfigure cubeos-set-sd-dirclean
	rm -f $(BUILD_DIR)/cubeos-set-sd-$(CUBEOS_SET_SD_VERSION)/.stamp_downloaded
	rm -f $(DL_DIR)/cubeos-set-sd-$(CUBEOS_SET_SD_VERSION).tar.gz

cubeos-set-sd-clean: cubeos-set-sd-clean-for-rebuild
	cd $(BUILD_DIR)/cubeos-set-sd-$(CUBEOS_SET_SD_VERSION)/$(CUBEOS_REPO_SET_SD_PATH); cubeos clean

$(eval $(generic-package))
