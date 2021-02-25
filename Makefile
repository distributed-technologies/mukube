
# Copy the config file into buildroot and invokes the buildscript.
default : buildroot
	cp config buildroot/.config
	$(MAKE) -C buildroot 
	cd buildroot/output/images && find | cpio -pd ../../../output
	mv output/rootfs.iso9660 output/rootfs.iso 

menuconfig : buildroot
	cp config buildroot/.config 
	$(MAKE) -C buildroot menuconfig
	cp buildroot/.config config

# Clones the stable branch of buildroot.
buildroot : 
	git clone --depth 1 --branch 2020.11.3 git://git.buildroot.net/buildroot
