#!/bin/bash

set -eu

chown cloudera-scm:cloudera-scm /opt/cloudera/parcel-repo

(
    count=10
    until nc -z db $DB_PORT_5432_TCP_PORT; do
        if [[ $((--count)) -lt 0 ]]; then
            echo 'Database timeout' >&2
            exit 1
        fi
        sleep 1
    done
)

/usr/share/cmf/schema/scm_prepare_database.sh \
    --host=db --port=$DB_PORT_5432_TCP_PORT  \
    --user=postgres --password=$DB_ENV_POSTGRES_PASSWORD \
    postgresql scm scm scm

source /etc/default/cloudera-scm-server
exec su \
    -s /bin/bash \
    -c 'exec /usr/sbin/cmf-server' \
    cloudera-scm
