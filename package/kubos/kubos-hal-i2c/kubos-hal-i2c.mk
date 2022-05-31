#####################################################
#
# Cube-OS Python I2C HAL Installation
#
#####################################################
CUBEOS_HAL_I2C_VERSION = $(CUBEOS_VERSION)
CUBEOS_HAL_I2C_LICENSE = Apache-2.0
CUBEOS_HAL_I2C_LICENSE_FILES = LICENSE
CUBEOS_HAL_I2C_SITE = $(BUILD_DIR)/cubeos-$(CUBEOS_HAL_I2C_VERSION)/hal/python-hal/i2c
CUBEOS_HAL_I2C_SITE_METHOD = local
CUBEOS_HAL_I2C_SETUP_TYPE = setuptools
CUBEOS_HAL_I2C_DEPENDENCIES = cubeos

$(eval $(python-package))