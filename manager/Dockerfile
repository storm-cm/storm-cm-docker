FROM storm-cm/host

RUN apt-get -q update \
    && DEBIAN_FRONTEND=noninteractive apt-get -qy install \
        --no-install-recommends \
        cloudera-manager-server \
        netcat-openbsd \
    && apt-get clean

#VOLUME /var/log/cloudera-scm-server
#VOLUME /opt/cloudera/parcel-repo

ADD entry.bash /
ENTRYPOINT ["/entry.bash"]
EXPOSE 7180
