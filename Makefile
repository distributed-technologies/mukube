
# Copy the config file into buildroot and invokes the buildscript.
default : buildroot
	cp config buildroot/.config
	$(MAKE) -C buildroot 


# Clones the stable branch of buildroot.
buildroot : 
	git clone --depth 1 --branch 2020.11.3 git://git.buildroot.net/buildroot
