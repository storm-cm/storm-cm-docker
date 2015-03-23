#!/bin/bash

set -eu

chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo

source /etc/default/cloudera-scm-server

exec su \
    -s /bin/bash \
    -c 'exec /usr/sbin/cmf-server' \
    cloudera-scm
