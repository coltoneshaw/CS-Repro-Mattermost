#!/bin/bash

echo "include '/files/postgres/primary/primary_config.conf'" >> /var/lib/postgresql/data/postgresql.conf

psql -U mmuser -d mattermost -c "create role replicauser with replication password 'replicauser_password' login"
psql -U mmuser -d mattermost -c "select pg_create_physical_replication_slot('replica_2_slot');"
psql -U mmuser -d mattermost -c "select pg_create_physical_replication_slot('replica_1_slot');"


echo "host    replication     replicauser    0.0.0.0/0   md5" >> /var/lib/postgresql/data/pg_hba.conf
