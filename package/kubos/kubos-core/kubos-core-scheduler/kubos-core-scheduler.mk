###############################################
#
# Cube-OS Application Service
#
###############################################

CUBEOS_CORE_SCHEDULER_POST_BUILD_HOOKS += SCHEDULER_BUILD_CMDS
CUBEOS_CORE_SCHEDULER_INSTALL_STAGING = YES
CUBEOS_CORE_SCHEDULER_POST_INSTALL_STAGING_HOOKS += SCHEDULER_INSTALL_STAGING_CMDS
CUBEOS_CORE_SCHEDULER_POST_INSTALL_TARGET_HOOKS += SCHEDULER_INSTALL_TARGET_CMDS
CUBEOS_CORE_SCHEDULER_POST_INSTALL_TARGET_HOOKS += SCHEDULER_INSTALL_INIT_SYSV

define SCHEDULER_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/scheduler-service && \
	PATH=$(PATH):~/.cargo/bin && \
	PKG_CONFIG_ALLOW_CROSS=1 CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package scheduler-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define SCHEDULER_INSTALL_STAGING_CMDS
	echo '[scheduler-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/scheduler-service
	echo 'ip = ${BR2_CUBEOS_CORE_SCHEDULER_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/scheduler-service
	echo -e 'port = ${BR2_CUBEOS_CORE_SCHEDULER_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/scheduler-service
	echo '[scheduler-service]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/scheduler-service
	echo -e 'schedules_dir = ${BR2_CUBEOS_CORE_SCHEDULER_REGISTRY}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/scheduler-service
endef

# Install the application into the rootfs file system
define SCHEDULER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/scheduler-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/scheduler-service \
		$(TARGET_DIR)/usr/sbin

	echo 'CHECK PROCESS scheduler-service PIDFILE /var/run/scheduler-service.pid' > $(TARGET_DIR)/etc/monit.d/scheduler-service.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_CORE_SCHEDULER_INIT_LVL}cubeos-core-scheduler start"' >> $(TARGET_DIR)/etc/monit.d/scheduler-service.cfg 
	echo '	IF ${BR2_CUBEOS_CORE_SCHEDULER_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_CORE_SCHEDULER_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/scheduler-service.cfg  
endef

# Install the init script
define SCHEDULER_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-core/cubeos-core-scheduler/cubeos-core-scheduler \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_CORE_SCHEDULER_INIT_LVL)cubeos-core-scheduler
endef

cubeos-core-scheduler-cargoclean: cubeos-core-scheduler-service-dirclean
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/scheduler-service && \
	PATH=$(PATH):~/.cargo/bin && \
	cargo clean

$(eval $(virtual-package))