
# Copy the config file into buildroot and invokes the buildscript.
default : buildroot copy_src
	$(MAKE) -C buildroot defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot 
	cd buildroot/output/images && find | cpio -pd ../../../output
	mv -f output/rootfs.iso9660 output/rootfs.iso 

# Uses the buildroot default configurations to save our configurations. 
menuconfig : buildroot static_file_override
	$(MAKE) -C buildroot defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot menuconfig
	$(MAKE) -C buildroot savedefconfig BR2_DEFCONFIG=../config

# Overwrites some static files in the buildroot project.
static_file_override : buildroot
	cp -fr src/* buildroot/

# Clones the stable branch of buildroot. 
# This is released every three months, the tag is YYYY.MM.x 
buildroot : 
	git clone --depth 1 --branch 2020.11.3 git://git.buildroot.net/buildroot

.PHONY : clean
clean :
	rm -rf output/*
