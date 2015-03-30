.DEFAULT_GOAL := build
SHELL := /bin/bash
, := ,

include docker.mk
include rootcmd.mk
include test-exec.mk

down_%:
	$(DOCKER) rm -f -v $(shell cat $*.cid)
	rm -f $*.cid

.PHONY: up
up: db.cid manager.cid

DOCKER_RUN := $(DOCKER) run -d \
	--dns=172.17.42.1

db.cid:
	$(DOCKER_RUN) \
		--cidfile=$@ \
		-e POSTGRES_PASSWORD=postgres \
		postgres:9.4

manager.cid: db.cid
	$(DOCKER_RUN) \
		--cidfile=$@ \
		--link='$(shell cat db.cid):db' \
		-P \
		--volume='$(abspath parcel-repo):/opt/cloudera/parcel-repo' \
		storm-cm/manager

agent%.cid: manager.cid db.cid
	$(DOCKER_RUN) \
		--cidfile=$@ \
		--link='$(shell cat db.cid):db' \
		storm-cm/agent

.PHONY: build
build: docker_storm-cm/manager docker_storm-cm/agent

.PHONY: docker_storm-cm/manager
docker_storm-cm/manager: docker_storm-cm/host
	$(call docker-build)

.PHONY: docker_storm-cm/agent
docker_storm-cm/agent: docker_storm-cm/host
	$(call docker-build)

.PHONY: docker_storm-cm/host
docker_storm-cm/host: $(call test-docker-image,storm-cm/host.tmp) $(addprefix host/,local_policy.jar US_export_policy.jar cloudera.gpg)
	$(call docker-build)
	$(DOCKER) rmi storm-cm/host.tmp

host/cloudera.gpg: $(call test-docker-image,storm-cm/debian)
	$(DOCKER) run \
		-t \
		--rm \
		-v $(abspath $(dir $@)):/build \
		-w /root \
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
		-w /root \
		storm-cm/debian \
		bash -c $$'\
			set -eu; \
			apt-get -q update; \
			apt-get -qy install --no-install-recommends ca-certificates wget unzip; \
			wget \
				--header \'Cookie: oraclelicense=accept-securebackup-cookie\' \
				https://edelivery.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip; \
			unzip -j -d . jce_policy-8.zip UnlimitedJCEPolicyJDK8/{local,US_export}_policy.jar; \
			cp -t /build *.jar; \
			mv -t /build jce_policy-8.zip; \
		'

docker_storm-cm/host.tmp: $(call test-docker-image,storm-cm/debian) host/oracle-java8-jre_8u40_amd64.deb
	set -eu; \
		if [[ -f host.tmp.cid ]]; then \
			$(DOCKER) rm -v $$(<host.tmp.cid) || :; \
			rm host.tmp.cid; \
		fi
	$(DOCKER) run \
		--cidfile=host.tmp.cid \
		-i \
		-w /root \
		storm-cm/debian \
		bash -c $$'\
			set -eu; \
			deb='$(notdir $(filter %.deb,$^))'; \
			cat /dev/stdin > "$$deb"; \
			ls -l "$$deb"; \
			dpkg -i "$$deb"; \
		' < $(filter %.deb,$^)
	$(DOCKER) commit \
		$$(<host.tmp.cid) \
		$(patsubst docker_%,%,$@)
	$(DOCKER) rm -v $$(<host.tmp.cid)
	rm host.tmp.cid

host/oracle-java8-jre_8u40_amd64.deb: $(call test-docker-image,storm-cm/debian)
	$(DOCKER) run \
		-t \
		--rm \
		-v $(abspath $(dir $@)):/build \
		-w /root \
		storm-cm/debian \
		bash -c $$'\
			set -eux; \
			echo \'deb http://http.debian.net/debian wheezy-backports main contrib non-free\' > /etc/apt/sources.list.d/backports.list; \
			apt-get -q update; \
			apt-get -qy install --no-install-recommends ca-certificates java-package/wheezy-backports gcc wget; \
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
