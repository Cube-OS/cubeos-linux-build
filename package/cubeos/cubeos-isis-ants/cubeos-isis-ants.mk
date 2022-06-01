###############################################
#
# Cube-OS ISIS Antenna Systems Service
#
###############################################

CUBEOS_ISIS_ANTS_POST_BUILD_HOOKS += ISIS_ANTS_BUILD_CMDS
CUBEOS_ISIS_ANTS_INSTALL_STAGING = YES
CUBEOS_ISIS_ANTS_POST_INSTALL_STAGING_HOOKS += ISIS_ANTS_INSTALL_STAGING_CMDS
CUBEOS_ISIS_ANTS_POST_INSTALL_TARGET_HOOKS += ISIS_ANTS_INSTALL_TARGET_CMDS
CUBEOS_ISIS_ANTS_POST_INSTALL_TARGET_HOOKS += ISIS_ANTS_INSTALL_INIT_SYSV

define ISIS_ANTS_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/isis-ants-service && \
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" CXX=$(TARGET_CXX) cargo cubeos -c build -t $(CUBEOS_TARGET) -- --release --package isis-ants-service
endef

# Generate the config settings for the service and add them to a fragment file
define ISIS_ANTS_INSTALL_STAGING_CMDS
	echo '[isis-ants-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
	echo 'ip = ${BR2_CUBEOS_ISIS_ANTS_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
	echo -e 'port = ${BR2_CUBEOS_ISIS_ANTS_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
	echo '[isis-ants-service]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
	echo 'bus = ${BR2_CUBEOS_ISIS_ANTS_BUS}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
	echo 'primary = ${BR2_CUBEOS_ISIS_ANTS_PRIMARY}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
	echo 'secondary = ${BR2_CUBEOS_ISIS_ANTS_SECONDARY}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
	echo 'antennas = ${BR2_CUBEOS_ISIS_ANTS_COUNT}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
	echo -e 'wd_timeout = ${BR2_CUBEOS_ISIS_ANTS_WDT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/isis-ants-service
endef

# Install the application into the rootfs file system
define ISIS_ANTS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/isis-ants-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/isis-ants-service \
		$(TARGET_DIR)/usr/sbin
		
	echo 'CHECK PROCESS cubeos-isis-ants PIDFILE /var/run/isis-ants-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-isis-ants.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_ISIS_ANTS_INIT_LVL}cubeos-isis-ants start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-isis-ants.cfg 
	echo '	IF ${BR2_CUBEOS_ISIS_ANTS_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_ISIS_ANTS_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-isis-ants.cfg 
endef

# Install the init script
define ISIS_ANTS_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-isis-ants/cubeos-isis-ants \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_ISIS_ANTS_INIT_LVL)cubeos-isis-ants
endef

$(eval $(virtual-package))