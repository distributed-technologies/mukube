# mukube

The mukube project aims to build a minimal linux image capable of running Kubernetes tools. The resulting image can be booted from a USB stick and runs entirely within RAM using a ramfs.  

To build the rootfs.iso simply run `make` from the main folder. This fetches the Buildroot toolchain and builds the iso. 

To run the accompanying tests go to the `testsuite` directory and run the command `runtest`. 


For more detailed documentation go to 

- [Setup](docs/setup.md)
- [Testing](docs/testing.md)
