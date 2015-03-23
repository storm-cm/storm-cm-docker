FROM storm-cm/host

RUN apt-get -q update \
    && apt-get -qy install \
        --no-install-recommends \
        python2.7 \
        cloudera-manager-agent \
    && apt-get clean

RUN mv /etc/cloudera-scm-agent/config.ini /etc/cloudera-scm-agent/config.ini.dpkg-dist
COPY config.ini /etc/cloudera-scm-agent/

# This is more convenient than setting via /api/v9/cm/allHosts/config
ENV JAVA_HOME /usr/lib/jvm/jre-8-oracle-x64

ENTRYPOINT ["/usr/sbin/cmf-agent"]
