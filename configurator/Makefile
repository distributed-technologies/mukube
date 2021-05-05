HELM_REQUIREMENTS ?= helm_requirements
IMAGE_REQUIREMENTS ?= image_requirements
CONFIG ?= config


default: $(CONFIG) docker-kubeadm pull-container-images pack-helm-charts
	./scripts/prepare_cluster.sh build/nodes $(CONFIG)
	./scripts/build_cluster.sh build/nodes


help:
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

CONTAINER_DIR = build/root/container-images
CONTAINER_IMAGES =

# The pull and save recipe template is created for each image in the IMAGE_REQUIREMENTS file
# This way images are pulled and saved only once. Every recipe is added to the CONTAINER_IMAGES list
# which lists all dependencies for the container-images target.
# We sanitize the image filenames replacing / and : with .
define PULL_AND_SAVE_IMAGE
CONTAINER_IMAGES += $(CONTAINER_DIR)/$(subst :,.,$(subst /,.,$1)).tar
$(CONTAINER_DIR)/$(subst :,.,$(subst /,.,$1)).tar : $(CONTAINER_DIR)/.empty
	docker pull $1 && docker save -o $$@ $1

endef

$(foreach I,$(shell cat $(IMAGE_REQUIREMENTS)),$(eval $(call PULL_AND_SAVE_IMAGE,$I)))

## pull-container-images: Pull and save all container images in IMAGE_REQUIREMENTS
.PHONY : pull-container-images
pull-container-images : $(CONTAINER_DIR)/.empty $(CONTAINER_IMAGES)
$(CONTAINER_DIR)/.empty :
	mkdir -p $(@D) && touch $@


HELM_DIR = build/root/helm-charts
# It is important that HELM_CHARTS is evaluated immediately ( := ) otherwise only the last helm package rule gets added
HELM_CHARTS := 

# Create make targets to download the helm packages specified in the HELM_REQUIREMENTS 
define DOWNLOAD_HELM_PACKAGE
release = $(shell echo $1 | cut -d % -f 1 )
namespace = $(shell echo $1 | cut -d % -f 2)
url = $(shell echo $1 | cut -d % -f 3- )
HELM_CHARTS += $(HELM_DIR)/$$(release)\#$$(namespace)\#$$(notdir $$(url))
$(HELM_DIR)/$$(release)\#$$(namespace)\#$$(notdir $$(url)) : $(HELM_DIR)/.empty
	curl -L $$(url) -o $$@ 
endef
$(foreach L,$(shell cat $(HELM_REQUIREMENTS)),$(eval $(call DOWNLOAD_HELM_PACKAGE,$L))) 

pack-helm-charts : $(HELM_DIR)/.empty $(HELM_CHARTS)
$(HELM_DIR)/.empty :
	mkdir -p $(@D) && touch $@ 


## docker-kubeadm: build the kubeadocker image used to generate join_tokens and certificates
.PHONY : docker-kubeadm
docker-kubeadm:
	docker build -t kubeadocker - < Dockerfile

## clean: remove output from the build
clean:
	rm -rf artifacts
	rm -rf build
