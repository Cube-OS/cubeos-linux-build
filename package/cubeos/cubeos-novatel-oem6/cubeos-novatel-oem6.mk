###############################################
#
# Cube-OS NovAtel OEM6 Service
#
###############################################

CUBEOS_NOVATEL_OEM6_POST_BUILD_HOOKS += OEM6_BUILD_CMDS
CUBEOS_NOVATEL_OEM6_INSTALL_STAGING = YES
CUBEOS_NOVATEL_OEM6_POST_INSTALL_STAGING_HOOKS += OEM6_INSTALL_STAGING_CMDS
CUBEOS_NOVATEL_OEM6_POST_INSTALL_TARGET_HOOKS += OEM6_INSTALL_TARGET_CMDS
CUBEOS_NOVATEL_OEM6_POST_INSTALL_TARGET_HOOKS += OEM6_INSTALL_INIT_SYSV

define OEM6_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/novatel-oem6-service && \
	PATH=$(PATH):~/.cargo/bin:/usr/bin/iobc_toolchain/usr/bin && \
	CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package novatel-oem6-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define OEM6_INSTALL_STAGING_CMDS
	echo '[novatel-oem6-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/novatel-oem6-service
	echo 'ip = ${BR2_CUBEOS_NOVATEL_OEM6_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/novatel-oem6-service
	echo -e 'port = ${BR2_CUBEOS_NOVATEL_OEM6_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/novatel-oem6-service
	echo '[novatel-oem6-service]' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/novatel-oem6-service
	echo -e 'bus = ${BR2_CUBEOS_NOVATEL_OEM6_BUS}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/novatel-oem6-service
endef

# Install the application into the rootfs file system
define OEM6_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/novatel-oem6-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/novatel-oem6-service \
		$(TARGET_DIR)/usr/sbin
				
	echo 'CHECK PROCESS cubeos-novatel-oem6 PIDFILE /var/run/novatel-oem6-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-novatel-oem6.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_NOVATEL_OEM6_INIT_LVL}cubeos-novatel-oem6 start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-novatel-oem6.cfg 
	echo '	IF ${BR2_CUBEOS_NOVATEL_OEM6_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_NOVATEL_OEM6_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-novatel-oem6.cfg 
endef

# Install the init script
define OEM6_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-novatel-oem6/cubeos-novatel-oem6 \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_NOVATEL_OEM6_INIT_LVL)cubeos-novatel-oem6
endef

$(eval $(virtual-package))