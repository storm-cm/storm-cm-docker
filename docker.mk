ifeq ($(UID),0)
    DOCKER := docker
else
    DOCKER := sudo -g docker docker
endif

define test-docker-image
$(if $(call test-exec,$(DOCKER) inspect $1),,docker-image-$(1))
endef

define docker-mkimage
.PHONY: docker-image-$1
docker-image-$1:
	$(ROOTCMD) \
            /usr/share/docker.io/contrib/mkimage.sh \
            -t $(1) \
	    $2
endef

define docker-build
$$(DOCKER) build --force-rm -t $$(patsubst docker-image-%,%,$$@) $$(dir $$(filter %/Dockerfile,$$^))
endef

define docker-image
.PHONY: docker-image-$1
docker-image-$1: $(subst storm-cm/,,$1)/Dockerfile
	#$(if $(filter-out,undefined,docker-image-$1-local),$(call docker-image-$1-local),)
	$(MAKE) $$@-local
	$(call docker-build)
.PHONY: docker-image-$1-local
docker-image-$1-local:
endef
