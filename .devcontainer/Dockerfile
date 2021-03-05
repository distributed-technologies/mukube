# Ubuntu version: bionic, focal
ARG VARIANT=focal
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}

# Buildroot dependencies, from the manual
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    sed make binutils build-essential gcc g++ bash patch gzip bzip2 \
    perl tar cpio unzip rsync file bc wget python3 python-is-python3 \
    libncurses-dev

# Kernel build dependencie, from https://www.kernel.org/doc/html/v4.10/process/changes.html
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    kmod jfsutils reiserfsprogs xfsprogs squashfs-tools btrfs-progs \
    quotatool ppp oprofile udev grub2 iptables openssl 

# Packages needed to run VM's via the commandline
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    qemu-kvm libvirt-dev libvirt-daemon-system bridge-utils dnsmasq virtinst

# DejaGnu test framework 
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y --no-install-recommends install dejagnu 

# Dependencies for starting running a VM

