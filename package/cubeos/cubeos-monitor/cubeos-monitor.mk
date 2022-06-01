###############################################
#
# Cube-OS Monitor Service
#
###############################################

CUBEOS_MONITOR_POST_BUILD_HOOKS += MONITOR_BUILD_CMDS
CUBEOS_MONITOR_INSTALL_STAGING = YES
CUBEOS_MONITOR_POST_INSTALL_STAGING_HOOKS += MONITOR_INSTALL_STAGING_CMDS
CUBEOS_MONITOR_POST_INSTALL_TARGET_HOOKS += MONITOR_INSTALL_TARGET_CMDS
CUBEOS_MONITOR_POST_INSTALL_TARGET_HOOKS += MONITOR_INSTALL_INIT_SYSV

define MONITOR_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/monitor-service && \
	PATH=$(PATH):~/.cargo/bin:/usr/bin/iobc_toolchain/usr/bin && \
	CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package monitor-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define MONITOR_INSTALL_STAGING_CMDS
	echo '[monitor-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/monitor-service
	echo 'ip = ${BR2_CUBEOS_MONITOR_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/monitor-service
	echo -e 'port = ${BR2_CUBEOS_MONITOR_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/monitor-service
endef

# Install the application into the rootfs file system
define MONITOR_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/monitor-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/monitor-service \
		$(TARGET_DIR)/usr/sbin
				
	echo 'CHECK PROCESS cubeos-monitor PIDFILE /var/run/monitor-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-monitor.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_MONITOR_INIT_LVL}cubeos-monitor start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-monitor.cfg 
	echo '	IF ${BR2_CUBEOS_MONITOR_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_MONITOR_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-monitor.cfg 
endef

# Install the init script
define MONITOR_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-monitor/cubeos-monitor \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_MONITOR_INIT_LVL)cubeos-monitor
endef

$(eval $(virtual-package))