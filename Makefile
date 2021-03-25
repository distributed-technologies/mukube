
# Recreate the config file in buildroot and invoke the buildscript.
default : buildroot bootloader-config-override binaries-overlay
	$(MAKE) -C buildroot BR2_EXTERNAL=../src defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot 
	cd buildroot/output/images && find | cpio -pd ../../../output
	mv -f output/rootfs.iso9660 output/rootfs.iso 

# Uses the buildroot default configurations to save our configurations. 
menuconfig : buildroot
	$(MAKE) -C buildroot BR2_EXTERNAL=../src defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot menuconfig
	$(MAKE) -C buildroot savedefconfig BR2_DEFCONFIG=../config

# Loads the defaultconfig into buildroot and edits the linux kernel config
linux-menuconfig : buildroot
	$(MAKE) -C buildroot BR2_EXTERNAL=../src defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot linux-menuconfig
	$(MAKE) -C buildroot linux-update-defconfig

# Overwrites static isolinux bootloader files in the buildroot project.
bootloader-config-override : buildroot
	cp -fr src/fs/iso9660/* buildroot/fs/iso9660/

.PHONY : binaries-overlay
binaries-overlay : src/board/rootfs_overlay/usr/bin/kubeadm src/board/rootfs_overlay/usr/bin/crictl

# We use kubeadm as a placeholder for all the installed kubernetes binaries. 
src/board/rootfs_overlay/usr/bin/kubeadm : 
	mkdir -p src/board/rootfs_overlay/usr 
	wget https://dl.k8s.io/v1.20.5/kubernetes-server-linux-amd64.tar.gz
	tar -xf kubernetes-server-linux-amd64.tar.gz -C src/board/rootfs_overlay/usr/ --strip-components=2 \
	--exclude='vendor' --exclude='LICENSE' --exclude='OWNERS'
	rm kubernetes-server-linux-amd64.tar.gz

src/board/rootfs_overlay/usr/bin/crictl : 
	mkdir -p src/board/rootfs_overlay/usr/bin
	wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.20.0/crictl-v1.20.0-linux-amd64.tar.gz
	tar -xf crictl-v1.20.0-linux-amd64.tar.gz -C src/board/rootfs_overlay/usr/bin --strip-components=0
	rm crictl-v1.20.0-linux-amd64.tar.gz

.PHONY : clean-overlay
clean-overlay :
	rm -rf src/board/rootfs_overlay/*

# Clones the stable branch of buildroot. 
# This is released every three months, the tag is YYYY.MM.x 
buildroot : 
	git clone --depth 1 --branch 2020.11.3 git://git.buildroot.net/buildroot

.PHONY : clean
clean :
	rm -rf output/*

.PHONY : distclean
distclean : clean-overlay clean
	$(MAKE) -C buildroot distclean
