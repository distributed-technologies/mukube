HELM_REQUIREMENTS ?= helm_requirements
IMAGE_REQUIREMENTS ?= image_requirements
CONFIG ?= config


default: $(CONFIG) docker-kubeadm pull-container-images build/root/helm-charts
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

## docker-kubeadm: build the kubeadocker image used to generate join_tokens and certificates
.PHONY : docker-kubeadm
docker-kubeadm:
	docker build -t kubeadocker - < Dockerfile

build/root/helm-charts: $(HELM_REQUIREMENTS)
	./scripts/pack_helm_charts.sh build/root/helm-charts $(HELM_REQUIREMENTS)

## clean: remove output from the build
clean:
	rm -rf artifacts
	rm -rf build
