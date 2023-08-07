###############################################
#
# cubeos-get-sd Command Binary
#
###############################################
CUBEOS_GET_SD_VERSION = $(call qstrip,$(BR2_CUBEOS_VERSION))
CUBEOS_GET_SD_LICENSE = Apache-2.0
CUBEOS_GET_SD_LICENSE_FILES = LICENSE
CUBEOS_GET_SD_REDISTRIBUTE = NO
CUBEOS_GET_SD_SITE = $(CUBEOS_GET_SD_PKGDIR).
CUBEOS_GET_SD_SITE_METHOD = local
CUBEOS_GET_SD_DEPENDENCIES = cubeos
# The path from the GET_SD module to the build artifact directory
CUBEOS_ARTIFACT_BUILD_PATH = build/$(CUBEOS_TARGET)/source

# Link the local Kubos modules
define CUBEOS_GET_SD_CONFIGURE_CMDS
	cd $(@D) && \
	cubeos link -a
endef

# Use the Kubos SDK to build the cubeos-get-sd application
define CUBEOS_GET_SD_BUILD_CMDS
	cd $(@D) && \
	PATH=$(PATH):/usr/bin/iobc_toolchain/usr/bin && \
	cubeos -t $(CUBEOS_TARGET) build
endef
# Install the application into the rootfs file system
define CUBEOS_GET_SD_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 0755 $(@D)/$(CUBEOS_ARTIFACT_BUILD_PATH)/cubeos-get-sd \
		$(TARGET_DIR)/usr/bin/cubeos-get-sd
endef

cubeos-get-sd-fullclean: cubeos-get-sd-clean-for-reconfigure cubeos-get-sd-dirclean
	rm -f $(BUILD_DIR)/cubeos-get-sd-$(CUBEOS_GET_SD_VERSION)/.stamp_downloaded
	rm -f $(DL_DIR)/cubeos-get-sd-$(CUBEOS_GET_SD_VERSION).tar.gz

cubeos-get-sd-clean: cubeos-get-sd-clean-for-rebuild
	cd $(BUILD_DIR)/cubeos-get-sd-$(CUBEOS_GET_SD_VERSION)/$(CUBEOS_REPO_GET_SD_PATH); cubeos clean

$(eval $(generic-package))