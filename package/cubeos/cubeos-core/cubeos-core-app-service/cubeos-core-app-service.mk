###############################################
#
# Cube-OS Application Service
#
###############################################

CUBEOS_CORE_APP_SERVICE_POST_BUILD_HOOKS += APP_SERVICE_BUILD_CMDS
CUBEOS_CORE_APP_SERVICE_INSTALL_STAGING = YES
CUBEOS_CORE_APP_SERVICE_POST_INSTALL_STAGING_HOOKS += APP_SERVICE_INSTALL_STAGING_CMDS
CUBEOS_CORE_APP_SERVICE_POST_INSTALL_TARGET_HOOKS += APP_SERVICE_INSTALL_TARGET_CMDS
CUBEOS_CORE_APP_SERVICE_POST_INSTALL_TARGET_HOOKS += APP_SERVICE_INSTALL_INIT_SYSV

define APP_SERVICE_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/app-service && \
	PATH=$(PATH):~/.cargo/bin && \
	PKG_CONFIG_ALLOW_CROSS=1 CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package cubeos-app-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define APP_SERVICE_INSTALL_STAGING_CMDS
	echo '[app-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/app-service
	echo 'ip = ${BR2_CUBEOS_CORE_APP_SERVICE_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/app-service
	echo -e 'port = ${BR2_CUBEOS_CORE_APP_SERVICE_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/app-service
	echo '[app-service]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/app-service
	echo -e 'registry-dir = ${BR2_CUBEOS_CORE_APP_SERVICE_REGISTRY}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/app-service
endef

# Install the application into the rootfs file system
define APP_SERVICE_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/cubeos-app-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/cubeos-app-service \
		$(TARGET_DIR)/usr/sbin

	echo 'CHECK PROCESS cubeos-app-service PIDFILE /var/run/cubeos-app-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-app-service.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_CORE_APP_SERVICE_INIT_LVL}cubeos-core-app-service start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-app-service.cfg 
	echo '	IF ${BR2_CUBEOS_CORE_APP_SERVICE_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_CORE_APP_SERVICE_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-app-service.cfg  
endef

# Install the init script
define APP_SERVICE_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-core/cubeos-core-app-service/cubeos-core-app-service \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_CORE_APP_SERVICE_INIT_LVL)cubeos-core-app-service
endef

cubeos-core-app-service-cargoclean: cubeos-core-app-service-dirclean
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/app-service && \
	PATH=$(PATH):~/.cargo/bin && \
	cargo clean

$(eval $(virtual-package))