###############################################
#
# Cube-OS Master Package
#
# This package downloads the Cube-OS repo,
# globally links all the modules, and sets the
# target for the subsequent Cube-OS child 
# packages
#
###############################################
CUBEOS_LICENSE = Apache-2.0
CUBEOS_LICENSE_FILES = LICENSE
CUBEOS_SITE = https://github.com/Cube-OS/cubeOS
CUBEOS_SITE_METHOD = git
# CUBEOS_PROVIDES = cubeos-mai400
CUBEOS_INSTALL_STAGING = YES
CUBEOS_TARGET_FINALIZE_HOOKS += CUBEOS_CREATE_CONFIG

CUBEOS_CONFIG_FRAGMENT_DIR = $(STAGING_DIR)/etc/cubeos
CUBEOS_CONFIG_FILE = $(TARGET_DIR)/etc/cubeos-config.toml

VERSION = $(call qstrip,$(BR2_CUBEOS_VERSION))
# If the version specified is a branch name, we need to go fetch the SHA1 for the branch's HEAD
ifeq ($(shell git ls-remote --heads $(CUBEOS_SITE) $(VERSION) | wc -l), 1)
	CUBEOS_VERSION := $(shell git ls-remote $(CUBEOS_SITE) $(VERSION) | cut -c1-8)
else
	CUBEOS_VERSION = $(VERSION)
endif

CUBEOS_BR_TARGET = $(lastword $(subst /, ,$(dir $(BR2_LINUX_KERNEL_CUSTOM_DTS_PATH))))
ifeq ($(CUBEOS_BR_TARGET),at91sam9g20isis)
	CUBEOS_TARGET = cubeos-linux-isis-gcc
	CARGO_TARGET = armv5te-unknown-linux-gnueabi
else ifeq ($(CUBEOS_BR_TARGET),pumpkin-mbm2)
	CUBEOS_TARGET = cubeos-linux-pumpkin-mbm2-gcc
	CARGO_TARGET = arm-unknown-linux-gnueabihf
else ifeq ($(CUBEOS_BR_TARGET),beaglebone-black)
	CUBEOS_TARGET = cubeos-linux-beaglebone-gcc
	CARGO_TARGET = arm-unknown-linux-gnueabihf
else
	CUBEOS_TARGET = unknown
endif

CARGO_OUTPUT_DIR = target/$(CARGO_TARGET)/release

define CUBEOS_INSTALL_STAGING_CMDS
	mkdir -p $(CUBEOS_CONFIG_FRAGMENT_DIR)
endef

define CUBEOS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/etc/monit.d
endef

define CUBEOS_CREATE_CONFIG
	# Collect all config fragment files into the final master config.toml file
	cat $(CUBEOS_CONFIG_FRAGMENT_DIR)/* > $(CUBEOS_CONFIG_FILE)
endef


cubeos-deepclean:
	rm -fR $(BUILD_DIR)/cubeos-*
	rm -f $(DL_DIR)/cubeos-*
	rm -f $(TARGET_DIR)/etc/init.d/*cubeos*
	rm -f $(TARGET_DIR)/etc/monit.d/cubeos*
	rm -fR $(CUBEOS_CONFIG_FRAGMENT_DIR)
	rm -fR $(BUILD_DIR)/../staging/etc/cubeos
	rm -f $(CUBEOS_CONFIG_FILE)

cubeos-fullclean: cubeos-clean-for-reconfigure cubeos-dirclean
	rm -f $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/.stamp_downloaded
	rm -f $(DL_DIR)/cubeos-$(CUBEOS_VERSION).tar.gz
	rm -fR $(CUBEOS_CONFIG_FRAGMENT_DIR)
	rm -fR $(BUILD_DIR)/../staging/etc/cubeos
	rm -f $(CUBEOS_CONFIG_FILE)

cubeos-clean: cubeos-clean-for-rebuild
	rm -fR $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/target

$(eval $(generic-package))
