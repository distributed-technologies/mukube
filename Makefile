
# Copy the config file into buildroot and invokes the buildscript.
default : buildroot
	cp config buildroot/.config
	$(MAKE) -C buildroot 
	cd buildroot/output/images && find | cpio -pd ../../../output
	mv -f output/rootfs.iso9660 output/rootfs.iso 

menuconfig : buildroot
	cp config buildroot/.config 
	$(MAKE) -C buildroot menuconfig
	cp buildroot/.config config

# Clones the stable branch of buildroot. 
# This is released every three months, the tag is YYYY.MM.x 
buildroot : 
	git clone --depth 1 --branch 2020.11.3 git://git.buildroot.net/buildroot

.PHONY : clean
clean :
	rm -rf output/*

# starting the vm in the cloud.
# sudo virt-install --virt-type=kvm --name=mukubev3 --ram 512 --vcpus=1 --hvm --network network=default,model=e1000 --nodisk --livecd --graphics vnc --cdrom /home/andreas/mukube/output/rootfs.iso