include docker.mk
include rootcmd.mk
include test-exec.mk

DOCKER_IMAGES := storm-cm/manager storm-cm/agent storm-cm/db
SHELL := /bin/bash
, := ,

.PHONY: all
all: docker-image-storm-cm/manager docker-image-storm-cm/agent docker-image-storm-cm/db

docker-image-storm-cm/manager: $(call test-docker-image,storm-cm/host)

docker-image-storm-cm/agent: $(call test-docker-image,storm-cm/host)

docker-image-storm-cm/host: $(call test-docker-image,storm-cm/debian)
docker-image-storm-cm/host-local: oracle-java8-jre_8u40_amd64.deb
	cp -t host $(filter %.deb,$^)

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

$(foreach i,$(DOCKER_IMAGES),$(eval $(call docker-image,$i)))
