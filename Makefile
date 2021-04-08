BUILDROOT_BRANCH=2020.11.3
DOCKER_BUILD_IMAGE=mukube/mukube_builder
DOCKER_TEST_IMAGE=mukube/mukube_tester

# Recreate the config file in buildroot and invoke the buildscript.
default : buildroot binaries-overlay
	$(MAKE) -C buildroot BR2_EXTERNAL=../src:../minikube defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot
	cd buildroot/output/images && find | cpio -pd ../../../output
	mv -f output/rootfs.iso9660 output/rootfs.iso

# Uses the buildroot default configurations to save our configurations.
menuconfig : buildroot
	$(MAKE) -C buildroot BR2_EXTERNAL=../src:../minikube defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot menuconfig
	$(MAKE) -C buildroot savedefconfig BR2_DEFCONFIG=../config

# Loads the defaultconfig into buildroot and edits the linux kernel config
linux-menuconfig : buildroot
	$(MAKE) -C buildroot BR2_EXTERNAL=../src defconfig BR2_DEFCONFIG=../config
	$(MAKE) -C buildroot linux-menuconfig
	$(MAKE) -C buildroot linux-update-defconfig

build-in-container : 
	docker run --rm --workdir /workspace --volume $(CURDIR):/workspace \
	$(DOCKER_BUILD_IMAGE) make 

menuconfig-in-container :
	docker run -it --rm --workdir /workspace --volume $(CURDIR):/workspace \
	$(DOCKER_BUILD_IMAGE) make menuconfig

test-in-container : 
	docker run --privileged -it --rm --workdir /workspace \
	--volume $(CURDIR)/testsuite:/workspace --volume $(CURDIR)/output:/output \
	--device=/dev/kvm --device=/dev/net/tun \
	-v /sys/fs/cgroup:/sys/fs/cgroup:rw --cap-add=NET_ADMIN --cap-add=SYS_ADMIN \
	$(DOCKER_TEST_IMAGE) 

# build the docker images used by the make targets
docker-image : $(DOCKER_BUILD_IMAGE) $(DOCKER_TEST_IMAGE)
$(DOCKER_BUILD_IMAGE) : .devcontainer/Dockerfile.build
	docker build -t $@ -f $< $(dir $<) 
$(DOCKER_TEST_IMAGE) : .devcontainer/Dockerfile.test
	docker build -t $@ -f $< $(dir $<)


.PHONY : binaries-overlay
binaries-overlay : minikube/board/coreos/minikube/rootfs-overlay/usr/bin/kubeadm src/board/rootfs_overlay/usr/bin/kubeadm src/board/rootfs_overlay/usr/bin/crictl minikube/board/coreos/minikube/rootfs-overlay/usr/bin/helm src/board/rootfs_overlay/usr/bin/containerd 

# We use kubeadm as a placeholder for all the installed kubernetes binaries.
src/board/rootfs_overlay/usr/bin/kubeadm :
	mkdir -p src/board/rootfs_overlay/usr/bin
	wget -c https://dl.k8s.io/v1.20.5/kubernetes-server-linux-amd64.tar.gz
	tar -xf kubernetes-server-linux-amd64.tar.gz -C src/board/rootfs_overlay/usr/bin --strip-components=3 \
	--exclude=*.tar --exclude=*.docker_tag --exclude=**/LICENSES/**
	rm kubernetes-server-linux-amd64.tar.gz

minikube/board/coreos/minikube/rootfs-overlay/usr/bin/kubeadm :
	mkdir -p minikube/board/coreos/minikube/rootfs-overlay/usr/bin
	wget -c https://dl.k8s.io/v1.20.5/kubernetes-server-linux-amd64.tar.gz
	tar -xf kubernetes-server-linux-amd64.tar.gz -C minikube/board/coreos/minikube/rootfs-overlay/usr/bin --strip-components=3 \
	--exclude=*.tar --exclude=*.docker_tag --exclude=**/LICENSES/**
	rm kubernetes-server-linux-amd64.tar.gz

src/board/rootfs_overlay/usr/bin/crictl :
	mkdir -p src/board/rootfs_overlay/usr/bin
	wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.20.0/crictl-v1.20.0-linux-amd64.tar.gz
	tar -xf crictl-v1.20.0-linux-amd64.tar.gz -C src/board/rootfs_overlay/usr/bin --strip-components=0
	rm crictl-v1.20.0-linux-amd64.tar.gz

minikube/board/coreos/minikube/rootfs-overlay/usr/bin/helm :
	mkdir -p minikube/board/coreos/minikube/rootfs-overlay/usr/bin
	wget -c https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz
	tar -xf helm-v3.5.3-linux-amd64.tar.gz -C minikube/board/coreos/minikube/rootfs-overlay/usr/bin --strip-components=1 --exclude='LICENSE' --exclude='README.md'
	rm helm-v3.5.3-linux-amd64.tar.gz

src/board/rootfs_overlay/usr/bin/containerd :
	mkdir -p src/board/rootfs_overlay/usr/bin
	wget -c https://github.com/containerd/containerd/releases/download/v1.4.4/cri-containerd-cni-1.4.4-linux-amd64.tar.gz
	tar -xf cri-containerd-cni-1.4.4-linux-amd64.tar.gz -C src/board/rootfs_overlay/
	mv src/board/rootfs_overlay/usr/local/bin/* src/board/rootfs_overlay/usr/bin/
	mv src/board/rootfs_overlay/usr/local/sbin/* src/board/rootfs_overlay/usr/bin/
	rmdir src/board/rootfs_overlay/usr/local/bin src/board/rootfs_overlay/usr/local/sbin src/board/rootfs_overlay/usr/local
	rm cri-containerd-cni-1.4.4-linux-amd64.tar.gz


.PHONY : clean-overlay
clean-overlay :
	rm -rf src/board/rootfs_overlay/usr/*
	rm -rf src/board/rootfs_overlay/opt/*

# Clones the stable branch of buildroot.
# This is released every three months, the tag is YYYY.MM.x
buildroot :
	git clone --depth 1 --branch $(BUILDROOT_BRANCH) git://git.buildroot.net/buildroot

# Clone the mukube-configurator
mukube-configurator :
	git clone https://github.com/distributed-technologies/mukube-configurator.git


.PHONY : clean
clean :
	rm -rf output/*

.PHONY : distclean
distclean : clean-overlay clean
	$(MAKE) -C buildroot distclean
