BUILDROOT_BRANCH=2020.11.3
DOCKER_BUILD_IMAGE=mukube/mukube_builder
DOCKER_TEST_IMAGE=mukube/mukube_tester
ISO_NAME ?= rootfs.iso

# Recreate the config file in buildroot and invoke the buildscript.
default : buildroot binaries-overlay
	$(MAKE) -C buildroot BR2_EXTERNAL=../external_tree defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot
	mkdir -p output 
	mv -f buildroot/output/images/rootfs.iso9660 output/$(ISO_NAME)

# Uses the buildroot default configurations to save our configurations.
menuconfig : buildroot
	$(MAKE) -C buildroot BR2_EXTERNAL=../external_tree defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot menuconfig
	$(MAKE) -C buildroot savedefconfig BR2_DEFCONFIG=../config

# Loads the defaultconfig into buildroot and edits the linux kernel config
linux-menuconfig : buildroot
	$(MAKE) -C buildroot BR2_EXTERNAL=../external_tree defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot linux-menuconfig
	$(MAKE) -C buildroot linux-update-defconfig

build-in-container : 
	docker run --rm --workdir /workspace --volume $(CURDIR):/workspace \
	$(DOCKER_BUILD_IMAGE) make 

menuconfig-in-container :
	docker run -it --rm --workdir /workspace --volume $(CURDIR):/workspace \
	$(DOCKER_BUILD_IMAGE) make menuconfig

test-in-container : 
	docker run --privileged -it --rm --workdir /workspace \
	--volume $(CURDIR)/testsuite:/workspace --volume $(CURDIR)/output:/output \
	--device=/dev/kvm --device=/dev/net/tun \
	-v /sys/fs/cgroup:/sys/fs/cgroup:rw --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
	$(DOCKER_TEST_IMAGE) 

# build the docker images used by the make targets
docker-image : $(DOCKER_BUILD_IMAGE) $(DOCKER_TEST_IMAGE)

$(DOCKER_BUILD_IMAGE) : .devcontainer/Dockerfile.build
	docker build -t $@ -f $< $(dir $<) 

$(DOCKER_TEST_IMAGE) : .devcontainer/Dockerfile.test
	docker build -t $@ -f $< $(dir $<)

OVERLAY_DIR = external_tree/board/rootfs-overlay
BINARIES = 

BINARIES += $(OVERLAY_DIR)/usr/bin/kubeadm
# We use kubeadm as a placeholder for all the installed kubernetes binaries.
$(OVERLAY_DIR)/usr/bin/kubeadm :
	mkdir -p $(OVERLAY_DIR)/usr/bin
	wget -c https://dl.k8s.io/v1.20.5/kubernetes-server-linux-amd64.tar.gz
	tar -xf kubernetes-server-linux-amd64.tar.gz -C $(OVERLAY_DIR)/usr/bin --strip-components=3 \
	--exclude=*.tar --exclude=*.docker_tag --exclude=**/LICENSES/**
	rm kubernetes-server-linux-amd64.tar.gz

.PHONY : binaries-overlay
binaries-overlay : $(BINARIES)

# Clones the stable branch of buildroot.
# This is released every three months, the tag is YYYY.MM.x
buildroot :
	git clone --depth 1 --branch $(BUILDROOT_BRANCH) git://git.buildroot.net/buildroot


CONFIGURATOR_ARTIFACTS_DIR = overlay-artifacts
NODE_OVERLAY_DIR=external_tree/board/rootfs-node-overlay

TARGET_ISOS =
define ISO_MAKE_TARGET
TARGET_ISOS += output/$1.iso
output/$1.iso : 
	$$(MAKE) -j clean-buildroot-target clean-node-overlay 
	tar -xf $(CONFIGURATOR_ARTIFACTS_DIR)/$1.tar -C $(NODE_OVERLAY_DIR)
	ISO_NAME=$$(@F) $$(MAKE) 
endef

$(foreach T,$(shell ls $(CONFIGURATOR_ARTIFACTS_DIR)),$(eval $(call ISO_MAKE_TARGET,$(basename $T))))

.PHONY : cluster
cluster : $(TARGET_ISOS)
	@echo "Configure the cluster by running the configurator script"


## clean-buildroot-target: Removes target and images folders in buildroot and stamp files to remake them.
.PHONY : clean-buildroot-target
clean-buildroot-target :
	rm -rf buildroot/output/target/ buildroot/output/images/ 
	find buildroot/output -name ".stamp_target_installed" |xargs rm -rf 
	find buildroot/output -name ".stamp_images_installed" |xargs rm -rf 
	# The gcc package installs libraries with the POST_INSTALL_HOOK, so we need to force this step to happen again
	rm -rf buildroot/output/build/host-gcc-final-*/.stamp_host_installed

.PHONY : clean-node-overlay
clean-node-overlay : 
	rm -rf $(NODE_OVERLAY_DIR)/* 

.PHONY : clean-binaries-overlay
clean-binaries-overlay : 
	rm -rf $(OVERLAY_DIR)/usr/bin

.PHONY : clean
clean :
	rm -rf output/*

.PHONY : distclean
distclean : clean clean-node-overlay
	$(MAKE) -C buildroot distclean
