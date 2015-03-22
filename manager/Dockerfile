FROM storm-cm/host

RUN apt-get -q update \
    && apt-get -qy install \
        --no-install-recommends \
        cloudera-manager-server

#RUN adduser --system --group cloudera-scm

ENV JAVA_HOME /usr/lib/jvm/jdk-8-oracle-x64/jre
# Defaults taken from /etc/default/cloudera-scm-server
ENTRYPOINT ["/bin/sh", "-c", "set -e; . /etc/default-cloudera-scm-server; su cloudera-scm-server -c '/usr/sbin/cmf-server']
ENV CMF_JAVA_OPTS CMF_JAVA_OPTS=-Xmx2G -XX:MaxPermSize=256m -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp
