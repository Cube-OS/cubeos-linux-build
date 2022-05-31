#####################################################
#
# Pumpkin Stack Gating Watchdog Enable Installation
#
#####################################################
CUBEOS_PUMPKIN_WDT_VERSION = $(CUBEOS_VERSION)
CUBEOS_PUMPKIN_WDT_LICENSE = Apache-2.0
CUBEOS_PUMPKIN_WDT_LICENSE_FILES = LICENSE
CUBEOS_PUMPKIN_WDT_SITE = $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-pumpkin-wdt
CUBEOS_PUMPKIN_WDT_SITE_METHOD = local

# Install the init script
define CUBEOS_PUMPKIN_WDT_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-pumpkin-wdt/cubeos-pumpkin-wdt \
	    $(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_PUMPKIN_WDT_INIT_LVL)cubeos-pumpkin-wdt
    $(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-pumpkin-wdt/pumpkin-wdt-enable.sh \
	    $(TARGET_DIR)/usr/bin/pumpkin-wdt-enable.sh
endef

$(eval $(generic-package))