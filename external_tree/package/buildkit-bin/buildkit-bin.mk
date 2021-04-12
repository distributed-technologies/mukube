################################################################################
#
# buildkit-bin
#
################################################################################

BUILDKIT_BIN_VERSION = v0.8.1
BUILDKIT_BIN_COMMIT = 8142d66b5ebde79846b869fba30d9d30633e74aa
BUILDKIT_BIN_SITE = https://github.com/moby/buildkit/releases/download/$(BUILDKIT_BIN_VERSION)
BUILDKIT_BIN_SOURCE = buildkit-$(BUILDKIT_BIN_VERSION).linux-amd64.tar.gz

# https://github.com/opencontainers/runc.git
BUILDKIT_RUNC_VERSION = 939ad4e3fcfa1ab531458355a73688c6f4ee5003

define BUILDKIT_BIN_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 \
		$(@D)/buildctl \
		$(TARGET_DIR)/usr/bin
	$(INSTALL) -D -m 0755 \
		$(@D)/buildkit-runc \
		$(TARGET_DIR)/usr/sbin
	$(INSTALL) -D -m 0755 \
		$(@D)/buildkitd \
		$(TARGET_DIR)/usr/sbin
endef

$(eval $(generic-package))
