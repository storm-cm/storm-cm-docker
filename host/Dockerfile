FROM storm-cm/host.tmp

RUN \
    dpkg-divert --add --local --rename /usr/lib/jvm/jre-8-oracle-x64/lib/security/local_policy.jar \
    && dpkg-divert --add --local --rename /usr/lib/jvm/jre-8-oracle-x64/lib/security/US_export_policy.jar
COPY local_policy.jar     /usr/lib/jvm/jre-8-oracle-x64/lib/security/
COPY US_export_policy.jar /usr/lib/jvm/jre-8-oracle-x64/lib/security/
ENV JAVA_HOME /usr/lib/jvm/jre-8-oracle-x64

COPY cloudera.gpg /etc/apt/trusted.gpg.d/
COPY cloudera.list /etc/apt/sources.list.d/
# Adduser is installed separately so that it will be configured (hence putting
# /etc/adduser.conf into place) before it is run by
# cloudera-manager-daemons.preinst.
RUN apt-get -q update \
    && DEBIAN_FRONTEND=noninteractive apt-get -qy install \
        --no-install-recommends \
        adduser \
    && DEBIAN_FRONTEND=noninteractive apt-get -qy install \
        cloudera-manager-daemons \
    && apt-get clean
