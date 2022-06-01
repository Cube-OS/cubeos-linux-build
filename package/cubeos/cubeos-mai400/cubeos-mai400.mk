###############################################
#
# Cube-OS MAI400 Service
#
###############################################

CUBEOS_MAI400_POST_BUILD_HOOKS += MAI400_BUILD_CMDS
CUBEOS_MAI400_INSTALL_STAGING = YES
CUBEOS_MAI400_POST_INSTALL_STAGING_HOOKS += MAI400_INSTALL_STAGING_CMDS
CUBEOS_MAI400_POST_INSTALL_TARGET_HOOKS += MAI400_INSTALL_TARGET_CMDS
CUBEOS_MAI400_POST_INSTALL_TARGET_HOOKS += MAI400_INSTALL_INIT_SYSV

define MAI400_BUILD_CMDS
	cd $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/services/mai400-service && \
	PATH=$(PATH):~/.cargo/bin:/usr/bin/iobc_toolchain/usr/bin && \
	CC=$(TARGET_CC) RUSTFLAGS="-Clinker=$(TARGET_CC)" cargo build --package mai400-service --target $(CARGO_TARGET) --release
endef

# Generate the config settings for the service and add them to a fragment file
define MAI400_INSTALL_STAGING_CMDS
	echo '[mai400-service.addr]' > $(CUBEOS_CONFIG_FRAGMENT_DIR)/mai400-service
	echo 'ip = ${BR2_CUBEOS_MAI400_IP}' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/mai400-service
	echo -e 'port = ${BR2_CUBEOS_MAI400_PORT}\n' >> $(CUBEOS_CONFIG_FRAGMENT_DIR)/mai400-service
endef

# Install the application into the rootfs file system
define MAI400_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/sbin
	PATH=$(PATH):~/.cargo/bin:$(HOST_DIR)/usr/bin && \
	arm-linux-strip $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/mai400-service
	$(INSTALL) -D -m 0755 $(BUILD_DIR)/cubeos-$(CUBEOS_VERSION)/$(CARGO_OUTPUT_DIR)/mai400-service \
		$(TARGET_DIR)/usr/sbin
		
	echo 'CHECK PROCESS cubeos-mai400 PIDFILE /var/run/mai400-service.pid' > $(TARGET_DIR)/etc/monit.d/cubeos-mai400.cfg
	echo '	START PROGRAM = "/etc/init.d/S${BR2_CUBEOS_MAI400_INIT_LVL}cubeos-mai400 start"' >> $(TARGET_DIR)/etc/monit.d/cubeos-mai400.cfg 
	echo '	IF ${BR2_CUBEOS_MAI400_RESTART_COUNT} RESTART WITHIN ${BR2_CUBEOS_MAI400_RESTART_CYCLES} CYCLES THEN TIMEOUT' \
	>> $(TARGET_DIR)/etc/monit.d/cubeos-mai400.cfg
endef

# Install the init script
define MAI400_INSTALL_INIT_SYSV
	$(INSTALL) -D -m 0755 $(BR2_EXTERNAL_CUBEOS_LINUX_PATH)/package/cubeos/cubeos-mai400/cubeos-mai400 \
		$(TARGET_DIR)/etc/init.d/S$(BR2_CUBEOS_MAI400_INIT_LVL)cubeos-mai400
endef

$(eval $(virtual-package))