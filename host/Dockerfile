FROM storm-cm/debian

COPY oracle-java8-jre_8u40_amd64.deb /root/
RUN \
    dpkg -i /root/oracle-java8-jre_8u40_amd64.deb \
    && dpkg-divert --add --local --rename /usr/lib/jvm/jre-8-oracle-x64/lib/security/local_policy.jar \
    && dpkg-divert --add --local --rename /usr/lib/jvm/jre-8-oracle-x64/lib/security/US_export_policy.jar
COPY local_policy.jar     /usr/lib/jvm/jre-8-oracle-x64/lib/security/
COPY US_export_policy.jar /usr/lib/jvm/jre-8-oracle-x64/lib/security/

COPY archive.key /root/
RUN apt-key add /root/archive.key
COPY cloudera.list /etc/apt/sources.list.d/
# Adduser is installed separately so that it will be configured (hence putting
# /etc/adduser.conf into place) before it is run by
# cloudera-manager-daemons.preinst.
RUN apt-get -q update \
    && apt-get -qy install \
        --no-install-recommends \
        adduser \
    && apt-get -qy install \
        cloudera-manager-daemons \
    && apt-get clean
