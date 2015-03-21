(
    set -x
    for db in scm amon rman metastore sentry nav navms; do
        echo "CREATE ROLE $db LOGIN PASSWORD '$db';"
        echo "CREATE DATABASE $db OWNER $db ENCODING 'UTF8';"
    done
    echo 'ALTER DATABASE metastore SET standard_conforming_strings = off;'
) | su postgres -c '/usr/lib/postgresql/9.4/bin/postgres --single'
