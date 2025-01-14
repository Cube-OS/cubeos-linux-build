###############################################
#
# Cube-OS ClydeSpace 3G EPS Service
#
###############################################

CUBEOS_CLYDE_3G_EPS_POST_BUILD_HOOKS += CLYDE_3G_EPS_BUILD_CMDS
CUBEOS_CLYDE_3G_EPS_INSTALL_STAGING = YES
CUBEOS_CLYDE_3G_EPS_POST_INSTALL_STAGING_HOOKS += CLYDE_3G_EPS_INSTALL_STAGING_CMDS
CUBEOS_CLYDE_3G_EPS_POST_INSTALL_TARGET_HOOKS += CLYDE_3G_EPS_INSTALL_TARGET_CMDS
CUBEOS_CLYDE_3G_EPS_POST_INSTALL_TARGET_HOOKS += CLYDE_3G_EPS_INSTALL_INIT_SYSV

define CLYDE_3G_EPS_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/clyde-3g-eps-service && \
	PATH=$(PATH):~/.cargo/bin && \
	CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package clyde-3g-eps-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define CLYDE_3G_EPS_INSTALL_STAGING_CMDS
	echo '[clyde-3g-eps-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/clyde-3g-eps-service
	echo 'ip = ${BR2_CUBEOS_CLYDE_3G_EPS_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/clyde-3g-eps-service
	echo -e 'port = ${BR2_CUBEOS_CLYDE_3G_EPS_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/clyde-3g-eps-service
	echo '[clyde-3g-eps-service]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/clyde-3g-eps-service
	echo -e 'bus = ${BR2_CUBEOS_CLYDE_3G_EPS_BUS}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/clyde-3g-eps-service
endef

# Install the application into the rootfs file system
define CLYDE_3G_EPS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/clyde-3g-eps-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/clyde-3g-eps-service \
		$(TARGET_DIR)/usr/sbin
		
	echo 'CHECK PROCESS cubeos-clyde-3g-eps PIDFILE /var/run/clyde-3g-eps-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-clyde-3g-eps.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_CLYDE_3G_EPS_INIT_LVL}cubeos-clyde-3g-eps start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-clyde-3g-eps.cfg 
	echo '	IF ${BR2_CUBEOS_CLYDE_3G_EPS_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_CLYDE_3G_EPS_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-clyde-3g-eps.cfg 
endef

# Install the init script
define CLYDE_3G_EPS_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-clyde-3g-eps/cubeos-clyde-3g-eps \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_CLYDE_3G_EPS_INIT_LVL)cubeos-clyde-3g-eps
endef

cubeos-clyde-3g-eps-cargoclean: cubeos-clyde-3g-eps-dirclean
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/clyde-3g-eps-service && \
	PATH=$(PATH):~/.cargo/bin && \
	cargo clean

$(eval $(virtual-package))