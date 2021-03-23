
# Recreate the config file in buildroot and invoke the buildscript.
default : buildroot static_file_override
	$(MAKE) -C buildroot BR2_EXTERNAL=../src defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot 
	cd buildroot/output/images && find | cpio -pd ../../../output
	mv -f output/rootfs.iso9660 output/rootfs.iso 

# Uses the buildroot default configurations to save our configurations. 
menuconfig : buildroot static_file_override
	$(MAKE) -C buildroot BR2_EXTERNAL=../src defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot menuconfig
	$(MAKE) -C buildroot savedefconfig BR2_DEFCONFIG=../config

# Overwrites static isolinux bootloader files in the buildroot project.
static_file_override : buildroot
	cp -fr src/fs/iso9660/* buildroot/fs/iso9660/

kubernetes :
	wget -c https://dl.k8s.io/v1.20.5/kubernetes-server-linux-amd64.tar.gz
	tar -xf kubernetes-server-linux-amd64.tar.gz -C src/board/rootfs_overlay/usr/ --strip-components=2 \
	--exclude='vendor' --exclude='LICENSE' --exclude='OWNERS'
	rm kubernetes-server-linux-amd64.tar.gz

cleankubernetes :
	rm -rf src/board/rootfs_overlay/usr/*

# Clones the stable branch of buildroot. 
# This is released every three months, the tag is YYYY.MM.x 
buildroot : 
	git clone --depth 1 --branch 2020.11.3 git://git.buildroot.net/buildroot

.PHONY : clean
clean :
	rm -rf output/*
