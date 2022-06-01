#####################################################
#
# Cube-OS Python Service Library Installation
#
#####################################################
CUBEOS_SERVICE_LIB_VERSION = $(CUBEOS_VERSION)
CUBEOS_SERVICE_LIB_LICENSE = Apache-2.0
CUBEOS_SERVICE_LIB_LICENSE_FILES = LICENSE
CUBEOS_SERVICE_LIB_SITE = $(BUILD_DIR)/cubeos-$(CUBEOS_SERVICE_LIB_VERSION)/libs/cubeos-service
CUBEOS_SERVICE_LIB_SITE_METHOD = local
CUBEOS_SERVICE_LIB_SETUP_TYPE = distutils
CUBEOS_SERVICE_LIB_DEPENDENCIES = cubeos

$(eval $(python-package))