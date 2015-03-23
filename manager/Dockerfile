FROM storm-cm/host

RUN apt-get -q update \
    && apt-get -qy install \
        --no-install-recommends \
        cloudera-manager-server \
        netcat-openbsd \
    && apt-get clean

#VOLUME /var/log/cloudera-scm-server
#VOLUME /opt/cloudera/parcel-repo

#ENV JAVA_HOME /usr/lib/jvm/jdk-8-oracle-x64/jre
ENV JAVA_HOME /usr/lib/jvm/jre-8-oracle-x64
ADD entry.bash /
ENTRYPOINT ["/entry.bash"]
EXPOSE 7180
