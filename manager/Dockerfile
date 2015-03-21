FROM storm-cm/debian

COPY oracle-java8-jre_8u40_amd64.deb /root/

RUN \
    dpkg -i /root/oracle-java8-jre_8u40_amd64.deb \
    && rm /root/oracle-java8-jre_8u40_amd64.deb
