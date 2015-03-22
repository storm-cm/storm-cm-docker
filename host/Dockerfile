FROM storm-cm/debian

COPY oracle-java8-jre_8u40_amd64.deb /root/
RUN \
    dpkg -i /root/oracle-java8-jre_8u40_amd64.deb

COPY archive.key /root/
RUN apt-key add /root/archive.key
COPY cloudera.list /etc/apt/sources.list.d/
RUN apt-get -q update \
    && apt-get -qy install \
        --no-install-recommends \
        adduser \
    && apt-get -qy install \
        cloudera-manager-daemons
# Adduser is installed separately so that it will be configured (hence
# putting /etc/adduser.conf into place) before cloudera-manager-daemons'
# preinst script runs it.
