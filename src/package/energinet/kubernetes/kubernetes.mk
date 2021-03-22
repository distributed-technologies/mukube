################################################################################
# 
# kubernetes
#
################################################################################
#KUBERNETES = bool

KUBERNETES_VERSION = 1.20.5
KUBERNETES_SITE = $(call github,kubernetes,kubernetes,v$(KUBERNETES_VERSION))

KUBERNETES_LICENSE = Apache-2.0
KUBERNETES_LICENSE_FILES = LICENSE 

# KUBERNETES_DEPENDENCIES = ?

$(eval $(golang-package))
