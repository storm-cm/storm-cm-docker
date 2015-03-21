include docker.mk
include rootcmd.mk
include test-exec.mk

SHELL := /bin/bash

, := ,

.PHONY: all
all: $(call test-docker-image,storm-cm/host) $(call test-docker-image,storm-cm/manager) $(call test-docker-image,storm-cm/db)

.PHONY: docker-image-storm-cm/host
docker-image-storm-cm/host: $(call test-docker-image,storm-cm/manager) host/Dockerfile
	$(call docker-build)

.PHONY: docker-image-storm-cm/manager
docker-image-storm-cm/manager: $(call test-docker-image,storm-cm/debian) oracle-java8-jre_8u40_amd64.deb manager/Dockerfile
	cp -t manager $(filter %.deb,$^)
	$(call docker-build)

.PHONY: docker-image-storm-cm/db
docker-image-storm-cm/db: $(call test-docker-image,storm-cm/debian) db/Dockerfile
	$(call docker-build)

oracle-java8-jre_8u40_amd64.deb: $(call test-docker-image,storm-cm/debian)
	$(ROOTCMD) docker run \
            -t \
            --rm \
            -v "$$PWD:/build" \
            $(patsubst docker-image-%,%,$<) \
            bash -c $$'\
                set -eux; \
                cd /tmp; \
                echo \'deb http://http.debian.net/debian wheezy-backports main contrib non-free\' > /etc/apt/sources.list.d/backports.list; \
                apt-get -q update; \
                apt-get -qy install --no-install-recommends ca-certificates java-package/wheezy-backports wget; \
                wget --progress=dot:mega --header \'Cookie: oraclelicense=accept-securebackup-cookie\' https://edelivery.oracle.com/otn-pub/java/jdk/8u40-b26/jre-8u40-linux-x64.tar.gz; \
                yes | su -c \'make-jpkg jre-8u40-linux-x64.tar.gz\' nobody; \
                mv -t /build $@; \
            '

$(eval $(call docker-mkimage,storm-cm/debian,\
    debootstrap \
        --variant=minbase \
        --components=main$(,)contrib$(,)non-free \
        wheezy \
        http://http.debian.net/debian \
))
