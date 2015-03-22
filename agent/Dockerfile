FROM storm-cm/host

COPY config.ini /etc/cloudera-scm-agent/
RUN apt-get -q update \
    && apt-get -qy install \
        --no-install-recommends \
        adduser cloudera-manager-agent
