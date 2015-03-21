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
$(DOCKER) build -t $(patsubst docker-image-%,%,$@) $(patsubst %/Dockerfile,%,$(filter %/Dockerfile,$^))
endef
