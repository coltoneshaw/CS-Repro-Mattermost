#!/bin/bash

set -e

## copying the base replica configuration and updating the primary slot name
cp /files/postgres/replica/base_replica_config.conf /files/postgres/replica/${REPLICA_NAME}.conf
sed -i "s/primary_slot_name = ''/primary_slot_name = '${REPLICA_NAME}_slot'/" /files/postgres/replica/${REPLICA_NAME}.conf

## copying the default postgres config and adding the replica specific configuration
echo "include '/files/postgres/replica/${REPLICA_NAME}.conf'" >> /var/lib/postgresql/data/postgresql.conf
cp /var/lib/postgresql/data/postgresql.conf /files/postgres/replica/${REPLICA_NAME}_postgres.conf

## Removing the pg data information to make way for the backup
rm -rf /var/lib/postgresql/data/*
export PGPASSWORD='replicauser_password'
pg_basebackup -h cs-repro-postgres -p 5432 -U replicauser -D /var/lib/postgresql/data -Fp -Xs -R

## Backup brings over the primary config, so we do not need it anymore.
rm -rf /var/lib/postgresql/data/postgresql.conf

## Bringing back in the replica specific config.
cp /files/postgres/replica/${REPLICA_NAME}_postgres.conf /var/lib/postgresql/data/postgresql.conf

exec pg_ctl -D /var/lib/postgresql/data start