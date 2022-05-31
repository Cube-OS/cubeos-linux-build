###############################################
#
# Cube-OS Telemetry Database Service
#
###############################################

CUBEOS_CORE_TELEMETRY_DB_POST_BUILD_HOOKS += TELEMETRY_DB_BUILD_CMDS
CUBEOS_CORE_TELEMETRY_DB_INSTALL_STAGING = YES
CUBEOS_CORE_TELEMETRY_DB_POST_INSTALL_STAGING_HOOKS += TELEMETRY_DB_INSTALL_STAGING_CMDS
CUBEOS_CORE_TELEMETRY_DB_POST_INSTALL_TARGET_HOOKS += TELEMETRY_DB_INSTALL_TARGET_CMDS
CUBEOS_CORE_TELEMETRY_DB_POST_INSTALL_TARGET_HOOKS += TELEMETRY_DB_INSTALL_INIT_SYSV

define TELEMETRY_DB_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/telemetry-service && \
	PATH=$(PATH):~/.cargo/bin && \
	CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package telemetry-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define TELEMETRY_DB_INSTALL_STAGING_CMDS
	echo '[telemetry-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/telemetry-service
	echo 'ip = ${BR2_CUBEOS_CORE_TELEMETRY_DB_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/telemetry-service
	echo -e 'port = ${BR2_CUBEOS_CORE_TELEMETRY_DB_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/telemetry-service
	echo '[telemetry-service]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/telemetry-service
	echo 'database = ${BR2_CUBEOS_CORE_TELEMETRY_DB_DATABASE}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/telemetry-service
	echo -e 'direct_port = ${BR2_CUBEOS_CORE_TELEMETRY_DB_DIRECT_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/telemetry-service
endef

# Install the application into the rootfs file system
define TELEMETRY_DB_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/telemetry-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/telemetry-service \
		$(TARGET_DIR)/usr/sbin
		
	echo 'CHECK PROCESS cubeos-telemetry-db PIDFILE /var/run/telemetry-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-telemetry-db.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_CORE_TELEMETRY_DB_INIT_LVL}cubeos-core-telemetry-db start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-telemetry-db.cfg 
	echo '	IF ${BR2_CUBEOS_CORE_TELEMETRY_DB_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_CORE_TELEMETRY_DB_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-telemetry-db.cfg  
endef

# Install the init script
define TELEMETRY_DB_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-core/cubeos-core-telemetry-db/cubeos-core-telemetry-db \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_CORE_TELEMETRY_DB_INIT_LVL)cubeos-core-telemetry-db
endef

cubeos-core-telemetry-db-cargoclean: cubeos-core-telemetry-db-dirclean
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/telemetry-service && \
	PATH=$(PATH):~/.cargo/bin && \
	cargo clean

$(eval $(virtual-package))
