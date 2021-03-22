
# Copy the config file into buildroot and invokes the buildscript.
default : buildroot copy_src
<<<<<<< HEAD
	$(MAKE) -C buildroot defconfig BR2_DEFCONFIG=../config
=======
	cp config buildroot/.config
>>>>>>> main
	$(MAKE) -C buildroot 
	cd buildroot/output/images && find | cpio -pd ../../../output
	mv -f output/rootfs.iso9660 output/rootfs.iso 

<<<<<<< HEAD
# Uses the buildroot default configurations to save our configurations. 
menuconfig : buildroot static_file_override
	$(MAKE) -C buildroot defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot menuconfig
	$(MAKE) -C buildroot savedefconfig BR2_DEFCONFIG=../config

# Overwrites some static files in the buildroot project.
static_file_override : buildroot
=======
# Copies the config into buildroot and opens buildroot config. When closed copies config back.
menuconfig : buildroot copy_src
	cp config buildroot/.config 
	$(MAKE) -C buildroot menuconfig
	cp buildroot/.config config

# Overwrites some static files in the buildroot project.
copy_src : buildroot
>>>>>>> main
	cp -fr src/* buildroot/

# Clones the stable branch of buildroot. 
# This is released every three months, the tag is YYYY.MM.x 
buildroot : 
	git clone --depth 1 --branch 2020.11.3 git://git.buildroot.net/buildroot

.PHONY : clean
clean :
	rm -rf output/*
