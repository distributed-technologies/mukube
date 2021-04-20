################################################################################
#
# helm
#
################################################################################
HELM_VERSION = v3.5.4
HELM_SITE = $(call github,helm,helm,$(HELM_VERSION))
HELM_LICENSE = apache-2.0
HELM_LICENSE_FILES = LICENSE
HELM_DEPENDENCIES = host-go

define HELM_BUILD_CMDS
	$(MAKE) -C $(@D)
endef

define HELM_INSTALL_TARGET_CMDS
	$(INSTALL) -Dm755 $(@D)/bin/helm $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
