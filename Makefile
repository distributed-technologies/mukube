
# Copy the config file into buildroot and invokes the buildscript.
default : buildroot copy_src
	cp config buildroot/.config
	$(MAKE) -C buildroot 
	cd buildroot/output/images && find | cpio -pd ../../../output
	mv -f output/rootfs.iso9660 output/rootfs.iso 

# Copies the config into buildroot and opens buildroot config. When closed copies config back.
menuconfig : buildroot copy_src
	cp config buildroot/.config 
	$(MAKE) -C buildroot menuconfig
	cp buildroot/.config config

# Overwrites static isolinux bootloader files in the buildroot project.
copy_src : buildroot
	cp -fr src/fs/iso9660/* buildroot/fs/iso9660/

# Clones the stable branch of buildroot. 
# This is released every three months, the tag is YYYY.MM.x 
buildroot : 
	git clone --depth 1 --branch 2020.11.3 git://git.buildroot.net/buildroot

.PHONY : clean
clean :
	rm -rf output/*
