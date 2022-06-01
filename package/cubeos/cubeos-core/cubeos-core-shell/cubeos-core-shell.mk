###############################################
#
# Cube-OS Shell Service
#
###############################################

CUBEOS_CORE_SHELL_POST_BUILD_HOOKS += SHELL_BUILD_CMDS
CUBEOS_CORE_SHELL_INSTALL_STAGING = YES
CUBEOS_CORE_SHELL_POST_INSTALL_STAGING_HOOKS += SHELL_INSTALL_STAGING_CMDS
CUBEOS_CORE_SHELL_POST_INSTALL_TARGET_HOOKS += SHELL_INSTALL_TARGET_CMDS
CUBEOS_CORE_SHELL_POST_INSTALL_TARGET_HOOKS += SHELL_INSTALL_INIT_SYSV

define SHELL_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/shell-service && \
	PATH=$(PATH):~/.cargo/bin && \
	CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package shell-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define SHELL_INSTALL_STAGING_CMDS
	echo '[shell-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/shell-service
	echo 'ip = ${BR2_CUBEOS_CORE_SHELL_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/shell-service
	echo -e 'port = ${BR2_CUBEOS_CORE_SHELL_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/shell-service
	
endef

# Install the application into the rootfs file system
define SHELL_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/shell-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/shell-service \
		$(TARGET_DIR)/usr/sbin
		
	echo 'CHECK PROCESS cubeos-shell-service PIDFILE /var/run/shell-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-shell-service.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_CORE_SHELL_INIT_LVL}cubeos-core-shell start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-shell-service.cfg 
	echo '	IF ${BR2_CUBEOS_CORE_SHELL_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_CORE_SHELL_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-shell-service.cfg
endef

# Install the init script
define SHELL_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-core/cubeos-core-shell/cubeos-core-shell \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_CORE_SHELL_INIT_LVL)cubeos-core-shell
endef

cubeos-core-shell-cargoclean: cubeos-core-shell-dirclean
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/shell-service && \
	PATH=$(PATH):~/.cargo/bin && \
	cargo clean

$(eval $(virtual-package))
