SHELL := /bin/bash
, := ,

include docker.mk
include rootcmd.mk
include test-exec.mk

.PHONY: all
all: docker_storm-cm/manager docker_storm-cm/agent

.PHONY: docker_storm-cm/manager
docker_storm-cm/manager: docker_storm-cm/host
	$(call docker-build)

.PHONY: docker_storm-cm/agent
docker_storm-cm/agent: docker_storm-cm/host
	$(call docker-build)

.PHONY: docker_storm-cm/host
docker_storm-cm/host: $(call test-docker-image,storm-cm/debian) host/oracle-java8-jre_8u40_amd64.deb host/local_policy.jar host/US_export_policy.jar host/cloudera.gpg
	$(call docker-build)

host/cloudera.gpg: $(call test-docker-image,storm-cm/debian)
	$(DOCKER) run \
		-t \
		--rm \
		-v $(abspath $(dir $@)):/build \
		-w /tmp \
		storm-cm/debian \
		bash -c $$'\
			set -x; \
			gpg --no-default-keyring --keyring $$(readlink -f $(notdir $@)) --import < /build/archive.key; \
			chmod 0644 $(notdir $@); \
			mv -t /build $(notdir $@); \
		'

host/local_policy.jar: host/jce_policy-8.zip
host/US_export_policy.jar: host/jce_policy-8.zip

# Note that the jars are copied, and the zip is moved; this ensures that the
# modification time of the zip is older than that of the jars; hence make will
# not think that the jar targets are outdated.
host/jce_policy-8.zip: $(call test-docker-image,storm-cm/debian)
	$(DOCKER) run \
		-t \
		--rm \
		-v $(abspath $(dir $@)):/build \
		-w /tmp \
		storm-cm/debian \
		bash -c $$'\
			apt-get -q update; \
			apt-get -qy install --no-install-recommends ca-certificates wget unzip; \
			wget \
				--header \'Cookie: oraclelicense=accept-securebackup-cookie\' \
				https://edelivery.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip; \
			unzip -j -d . jce_policy-8.zip UnlimitedJCEPolicyJDK8/{local,US_export}_policy.jar; \
			cp -t /build *.jar; \
			mv -t /build jce_policy-8.zip; \
		'

host/oracle-java8-jre_8u40_amd64.deb: $(call test-docker-image,storm-cm/debian)
	$(DOCKER) run \
		-t \
		--rm \
		-v $(abspath $(dir $@)):/build \
		-w /tmp \
		storm-cm/debian \
		bash -c $$'\
			set -eux; \
			echo \'deb http://http.debian.net/debian wheezy-backports main contrib non-free\' > /etc/apt/sources.list.d/backports.list; \
			apt-get -q update; \
			apt-get -qy install --no-install-recommends ca-certificates java-package/wheezy-backports wget; \
			wget --progress=dot:mega --header \'Cookie: oraclelicense=accept-securebackup-cookie\' https://edelivery.oracle.com/otn-pub/java/jdk/8u40-b26/jre-8u40-linux-x64.tar.gz; \
			yes | su -s /bin/sh -c \'make-jpkg jre-8u40-linux-x64.tar.gz\' nobody; \
			mv -t /build $(notdir $@); \
		'

$(eval $(call docker-mkimage,storm-cm/debian,\
	debootstrap \
		--variant=minbase \
		--components=main$(,)contrib$(,)non-free \
		wheezy \
		http://http.debian.net/debian \
))
