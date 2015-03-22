FROM storm-cm/debian

COPY oracle-java8-jre_8u40_amd64.deb /root/
RUN \
    dpkg -i /root/oracle-java8-jre_8u40_amd64.deb

COPY archive.key /root/
RUN apt-key add /root/archive.key
COPY cloudera.list /etc/apt/sources.list.d/
