###############################################
#
# Cube-OS NSL Duplex Comms Service
#
###############################################

CUBEOS_NSL_DUPLEX_DEPENDENCIES = cubeos

CUBEOS_NSL_DUPLEX_POST_BUILD_HOOKS += NSL_DUPLEX_BUILD_CMDS
CUBEOS_NSL_DUPLEX_INSTALL_STAGING = YES
CUBEOS_NSL_DUPLEX_POST_INSTALL_STAGING_HOOKS += NSL_DUPLEX_INSTALL_STAGING_CMDS
CUBEOS_NSL_DUPLEX_POST_INSTALL_TARGET_HOOKS += NSL_DUPLEX_INSTALL_TARGET_CMDS
CUBEOS_NSL_DUPLEX_POST_INSTALL_TARGET_HOOKS += NSL_DUPLEX_INSTALL_INIT_SYSV

define NSL_DUPLEX_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/nsl-duplex-d2-comms-service && \
	PATH=$(PATH):~/.cargo/bin:/usr/bin/iobc_toolchain/usr/bin && \
	PKG_CONFIG_ALLOW_CROSS=1 CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package nsl-duplex-d2-comms-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define NSL_DUPLEX_INSTALL_STAGING_CMDS
	echo '[nsl-duplex-comms-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo 'ip = ${BR2_CUBEOS_NSL_DUPLEX_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo -e 'port = ${BR2_CUBEOS_NSL_DUPLEX_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo '[nsl-duplex-comms-service.comms]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo 'ip = ${BR2_CUBEOS_NSL_DUPLEX_COMMS_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo 'max_num_handlers = ${BR2_CUBEOS_NSL_DUPLEX_HANDLERS}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	# KConfig doesn't have a list type, so we're just going to take a string (ex. "[1, 2, 3]") and strip the quotes
	echo 'downlink_ports = $(patsubst "%",%,${BR2_CUBEOS_NSL_DUPLEX_DOWNLINK_PORTS})' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo -e 'timeout = ${BR2_CUBEOS_NSL_DUPLEX_TIMEOUT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo '[nsl-duplex-comms-service]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo 'bus = ${BR2_CUBEOS_NSL_DUPLEX_BUS}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
	echo -e 'ping_freq = ${BR2_CUBEOS_NSL_DUPLEX_PING}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/nsl-duplex-d2-comms-service
endef

# Install the application into the rootfs file system
define NSL_DUPLEX_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/nsl-duplex-d2-comms-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/nsl-duplex-d2-comms-service \
		$(TARGET_DIR)/usr/sbin
		
	echo 'CHECK PROCESS nsl-duplex-d2-comms-service PIDFILE /var/run/nsl-duplex-d2-comms-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-nsl-duplex.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_NSL_DUPLEX_INIT_LVL}cubeos-nsl-duplex start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-nsl-duplex.cfg 
	echo '	IF ${BR2_CUBEOS_NSL_DUPLEX_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_NSL_DUPLEX_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-nsl-duplex.cfg
endef

# Install the init script
define NSL_DUPLEX_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-nsl-duplex/cubeos-nsl-duplex \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_NSL_DUPLEX_INIT_LVL)cubeos-nsl-duplex
endef

$(eval $(virtual-package))