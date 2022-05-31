###############################################
#
# Cube-OS File Transfer Service
#
###############################################

CUBEOS_CORE_FILE_TRANSFER_POST_BUILD_HOOKS += FILE_TRANSFER_BUILD_CMDS
CUBEOS_CORE_FILE_TRANSFER_INSTALL_STAGING = YES
CUBEOS_CORE_FILE_TRANSFER_POST_INSTALL_STAGING_HOOKS += FILE_TRANSFER_INSTALL_STAGING_CMDS
CUBEOS_CORE_FILE_TRANSFER_POST_INSTALL_TARGET_HOOKS += FILE_TRANSFER_INSTALL_TARGET_CMDS
CUBEOS_CORE_FILE_TRANSFER_POST_INSTALL_TARGET_HOOKS += FILE_TRANSFER_INSTALL_INIT_SYSV

define FILE_TRANSFER_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/file-service && \
	PATH=$(PATH):~/.cargo/bin && \
	CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package file-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define FILE_TRANSFER_INSTALL_STAGING_CMDS
	echo '[file-transfer-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo 'ip = ${BR2_CUBEOS_CORE_FILE_TRANSFER_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo -e 'port = ${BR2_CUBEOS_CORE_FILE_TRANSFER_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo '[file-transfer-service]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo 'storage_dir = ${BR2_CUBEOS_CORE_FILE_TRANSFER_STORAGE}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo 'timeout = ${BR2_CUBEOS_CORE_FILE_TRANSFER_TIMEOUT}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo 'chunk_size = ${BR2_CUBEOS_CORE_FILE_TRANSFER_CHUNK_SIZE}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo 'hold_count = ${BR2_CUBEOS_CORE_FILE_TRANSFER_HOLD_COUNT}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo 'downlink_ip = ${BR2_CUBEOS_CORE_FILE_TRANSFER_DOWNLINK_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
	echo -e 'downlink_port = ${BR2_CUBEOS_CORE_FILE_TRANSFER_DOWNLINK_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/file-service
endef

# Install the application into the rootfs file system
define FILE_TRANSFER_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/file-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/file-service \
		$(TARGET_DIR)/usr/sbin
		
	echo 'CHECK PROCESS file-service PIDFILE /var/run/file-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-file-service.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_CORE_FILE_TRANSFER_INIT_LVL}cubeos-core-file-transfer start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-file-service.cfg 
	echo '	IF ${BR2_CUBEOS_CORE_FILE_TRANSFER_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_CORE_FILE_TRANSFER_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-file-service.cfg  
endef

# Install the init script
define FILE_TRANSFER_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-core/cubeos-core-file-transfer/cubeos-core-file-transfer \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_CORE_FILE_TRANSFER_INIT_LVL)cubeos-core-file-transfer
endef

cubeos-core-file-transfer-cargoclean: cubeos-core-file-transfer-dirclean
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/file-service && \
	PATH=$(PATH):~/.cargo/bin && \
	cargo clean

$(eval $(virtual-package))
