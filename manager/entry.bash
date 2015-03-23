#!/bin/bash

set -eu

chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo

source /etc/default/cloudera-scm-server
export CMF_OPTS='-Dnetworkaddress.cache.ttl=0 -Dnetworkaddress.cache.negative.ttl=0'
exec su \
    -s /bin/bash \
    -c 'exec /usr/sbin/cmf-server' \
    cloudera-scm
