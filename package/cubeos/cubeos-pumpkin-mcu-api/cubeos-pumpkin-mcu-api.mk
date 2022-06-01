#####################################################
#
# Cube-OS Pumpkin MCU Python API Installation
#
#####################################################
CUBEOS_PUMPKIN_MCU_API_VERSION = $(CUBEOS_VERSION)
CUBEOS_PUMPKIN_MCU_API_LICENSE = Apache-2.0
CUBEOS_PUMPKIN_MCU_API_LICENSE_FILES = LICENSE
CUBEOS_PUMPKIN_MCU_API_SITE = $(BUILD_DIR)/cubeos-$(CUBEOS_PUMPKIN_MCU_API_VERSION)/apis/pumpkin-mcu-api
CUBEOS_PUMPKIN_MCU_API_SITE_METHOD = local
CUBEOS_PUMPKIN_MCU_API_SETUP_TYPE = setuptools
CUBEOS_PUMPKIN_MCU_API_DEPENDENCIES = cubeos

$(eval $(python-package))