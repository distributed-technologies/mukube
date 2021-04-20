# mukube

The mukube project builds a a minimal linux image capable of running Kubernetes and related tools. The resulting image can be booted from a USB stick and runs entirely within RAM.

Initially the project has borrowed parts of the minikube project. 

### Building the iso

To build the rootfs.iso simply run `make` from the main folder. This fetches the Buildroot toolchain and builds the iso. 

### Building a cluster
The project supports building iso's for an entire cluster. The cluster can be configured using the [mukube-configurator](https://github.com/distributed-technologies/mukube-configurator) project which is cloned into `/mukube-configurator` upon first running `make cluster`. 

To run the accompanying tests go to the `testsuite` directory and run the command `runtest`. 


For more detailed documentation go to 

- [Setup](docs/setup.md)
- [Testing](docs/testing.md)
