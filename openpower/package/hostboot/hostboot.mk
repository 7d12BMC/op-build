################################################################################
#
# hostboot for POWER9
#
################################################################################

HOSTBOOT_VERSION = $(call qstrip,$(BR2_HOSTBOOT_VERSION))
HOSTBOOT_SITE ?= $(call github,7d12BMC,hostboot,$(HOSTBOOT_VERSION))

HOSTBOOT_LICENSE = Apache-2.0
HOSTBOOT_LICENSE_FILES = LICENSE
HOSTBOOT_DEPENDENCIES = host-binutils

HOSTBOOT_INSTALL_IMAGES = YES
HOSTBOOT_INSTALL_TARGET = NO

ifeq ($(BR2_HOSTBOOT_USE_ALTERNATE_GCC),y)
HOSTBOOT_TARGET_CROSS = $(HOST_DIR)/alternate-toolchain/bin/$(GNU_TARGET_NAME)-
HOSTBOOT_BINUTILS_DIR = $(HOST_ALTERNATE_BINUTILS_DIR)
HOSTBOOT_DEPENDENCIES = host-alternate-binutils host-alternate-gcc
else
HOSTBOOT_TARGET_CROSS = $(TARGET_CROSS)
HOSTBOOT_BINUTILS_DIR = $(HOST_BINUTILS_DIR)
HOSTBOOT_DEPENDENCIES = host-binutils
endif

HOSTBOOT_ENV_VARS=$(TARGET_MAKE_ENV) PERL_USE_UNSAFE_INC=1 \
    CONFIG_FILE=$(BR2_EXTERNAL_OP_BUILD_PATH)/configs/hostboot/$(BR2_HOSTBOOT_CONFIG_FILE) \
    OPENPOWER_BUILD=1 CROSS_PREFIX="$(CCACHE) $(HOSTBOOT_TARGET_CROSS)" HOST_PREFIX="" \
    HOST_BINUTILS_DIR=$(HOSTBOOT_BINUTILS_DIR) HOSTBOOT_VERSION=`cat $(HOSTBOOT_VERSION_FILE)`

define HOSTBOOT_BUILD_CMDS
        $(HOSTBOOT_ENV_VARS) bash -c 'cd $(@D) && source ./env.bash && $(MAKE)'
endef

define HOSTBOOT_INSTALL_IMAGES_CMDS
        cd $(@D) && source ./env.bash && $(@D)/src/build/tools/hbDistribute --openpower $(STAGING_DIR)/hostboot_build_images/
endef

$(eval $(generic-package))
