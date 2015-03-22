FROM storm-cm/host

RUN apt-get -q update \
    && apt-get -qy install \
        --no-install-recommends \
        python2.7 \
        cloudera-manager-agent

RUN mv /etc/cloudera-scm-agent/config.ini /etc/cloudera-scm-agent/config.ini.dpkg-dist
COPY config.ini /etc/cloudera-scm-agent/

ENTRYPOINT ["/usr/sbin/cmf-agent"]
