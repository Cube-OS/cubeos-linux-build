#####################################################
#
# Cube-OS Python App API Installation
#
#####################################################
CUBEOS_APP_API_VERSION = $(CUBEOS_VERSION)
CUBEOS_APP_API_LICENSE = Apache-2.0
CUBEOS_APP_API_LICENSE_FILES = LICENSE
CUBEOS_APP_API_SITE = $(BUILD_DIR)/cubeos-$(CUBEOS_APP_API_VERSION)/apis/app-api/python
CUBEOS_APP_API_SITE_METHOD = local
CUBEOS_APP_API_SETUP_TYPE = setuptools
CUBEOS_APP_API_DEPENDENCIES = cubeos

$(eval $(python-package))