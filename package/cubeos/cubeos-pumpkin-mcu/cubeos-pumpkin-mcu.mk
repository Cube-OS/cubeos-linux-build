#####################################################
#
# Pumpkin MCU Python Service Installation
#
#####################################################
CUBEOS_PUMPKIN_MCU_VERSION = $(CUBEOS_VERSION)
CUBEOS_PUMPKIN_MCU_LICENSE = Apache-2.0
CUBEOS_PUMPKIN_MCU_LICENSE_FILES = LICENSE
CUBEOS_PUMPKIN_MCU_SITE = $(BUILD_DIR)/cubeos-$(CUBEOS_PUMPKIN_MCU_VERSION)/services/pumpkin-mcu-service
CUBEOS_PUMPKIN_MCU_SITE_METHOD = local
CUBEOS_PUMPKIN_MCU_DEPENDENCIES = cubeos

CUBEOS_PUMPKIN_MCU_INSTALL_STAGING = YES
CUBEOS_PUMPKIN_MCU_POST_INSTALL_STAGING_HOOKS += PUMPKIN_MCU_INSTALL_STAGING_CMDS

# Generate the config settings for the service and add them to a fragment file
define PUMPKIN_MCU_INSTALL_STAGING_CMDS
	echo '[pumpkin-mcu-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service
	echo 'ip = ${BR2_CUBEOS_PUMPKIN_MCU_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service
	echo -e 'port = ${BR2_CUBEOS_PUMPKIN_MCU_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service
	echo '[pumpkin-mcu-service.modules]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_SIM}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.sim]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_SIM_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_BIM}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.bim]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_BIM_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_PIM}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.pim]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_PIM_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_GPSRM}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.gpsrm]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_GPSRM_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_AIM2}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.aim2]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_AIM2_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service; \
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_RHM}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.rhm]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_RHM_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service; \
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_BSM}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.bsm]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_BSM_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service; \
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_BM2}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.bm2]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_BM2_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service; \
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_DASA}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.dasa]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_DASA_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service; \
	fi
	if [ "${BR2_CUBEOS_PUMPKIN_MCU_EPSM}" = "y" ] ; then \
		echo '[pumpkin-mcu-service.modules.epsm]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service;\
		echo 'address = ${BR2_CUBEOS_PUMPKIN_MCU_EPSM_ADDR}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service; \
	fi
	echo '' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/pumpkin-mcu-service
endef

# Install the application into the rootfs file system
define CUBEOS_PUMPKIN_MCU_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin/pumpkin-mcu-service
	cp -R $(@D)/* $(TARGET_DIR)/usr/sbin/pumpkin-mcu-service
endef

# Install the init script
define CUBEOS_PUMPKIN_MCU_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-pumpkin-mcu/cubeos-pumpkin-mcu \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_PUMPKIN_MCU_INIT_LVL)cubeos-pumpkin-mcu
endef

$(eval $(generic-package))