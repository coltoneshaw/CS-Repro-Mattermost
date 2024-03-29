#!/bin/bash

set -e

echo "include '/files/postgres/replica/replica_config.conf'" >> /var/lib/postgresql/data/postgresql.conf
cp /var/lib/postgresql/data/postgresql.conf /files/postgres/replica/baseconfig.conf


rm -rf /var/lib/postgresql/data/*
export PGPASSWORD='replicauser_password'
pg_basebackup -h cs-repro-postgres -p 5432 -U replicauser -D /var/lib/postgresql/data -Fp -Xs -R

rm -rf /var/lib/postgresql/data/postgresql.conf

cp /files/postgres/replica/baseconfig.conf /var/lib/postgresql/data/postgresql.conf

exec pg_ctl -D /var/lib/postgresql/data start