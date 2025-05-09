# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository contains a CS Repro Mattermost environment - a reproduction of a standard Mattermost customer production environment with preconfigured SAML, LDAP, Advanced Logging, Prometheus, Grafana, Elasticsearch, and read replicas. It is designed for testing and reproducing customer environments.

## Environment Setup

### Prerequisites

You need to have Docker and Docker Compose installed on your machine to run this environment.

### Initial Setup

1. Add an enterprise license file named `license.mattermost` to the root directory
2. Run `make run` to start the core services

## Common Commands

### Environment Management

- `make run` - Initialize environment and create containers
- `make run-all` - Spin up all environment containers (with DB replicas and Mattermost HA)
- `make run-db-replicas` - Add database replicas to the environment
- `make run-mm-replicas` - Add Mattermost HA nodes to the environment
- `make run-rtcd` - Launch RTCD service for Mattermost Calls
- `make start` - Start existing containers
- `make stop` - Stop all running containers
- `make restart` - Restart all containers
- `make restart-mattermost` - Restart only Mattermost containers (preferred for testing changes)
- `make backup-keycloak` - Generate a backup of the current Keycloak setup
- `make restore-keycloak` - Restore Keycloak data from an existing backup
- `make reset` - Clean volumes directory and reinitialize the environment
- `make delete-data` - Clear all data within volumes
- `make nuke` - Erase all configurations and data
- `make nuke-rmi` - Complete cleanup including removing Docker images

### Upgrading and Downgrading

To upgrade Mattermost:
1. Modify the image tag in `docker-compose.yml`
2. Run `make restart-mattermost`

To downgrade Mattermost:
1. Modify the image tag in `docker-compose.yml`
2. Run `make downgrade`

## Component Access

### Mattermost

- URL: http://localhost:8065
- Default credentials available in the accounts section below

### LDAP

- Admin access: `cn=admin,dc=planetexpress,dc=com` / `GoodNewsEveryone`
- Commands for LDAP operations are in the README.md

### Grafana

- URL: http://localhost:3000
- Credentials: admin / admin

### Elasticsearch

- URL: http://localhost:9200

### mitmproxy

- URL: http://localhost:8181

## Account Information

| Username  | Password  | Role in Mattermost | Can use LDAP? | Can use SAML? |
|-----------|-----------|-------------------|---------------|---------------|
| admin     | admin     | n/a               | n/a           | n/a           |
| professor | professor | Sys Admin         | Yes           | Yes           |
| bender    | bender    | Member            | Yes           | Yes           |
| hermes    | hermes    | Sys Admin         | Yes           | Yes           |
| fry       | fry       | Member            | Yes           | Yes           |
| leela     | leela     | Member            | Yes           | Yes           |
| zoidberg  | zoidberg  | Member            | Yes           | Yes           |
| amy       | amy       | Member            | Yes           | Yes           |

## Database Information

- Primary PostgreSQL: `postgresql://mmuser:mmuser_password@localhost:5432/mattermost`
- Replica 1: `postgresql://mmuser:mmuser_password@localhost:5433/mattermost`
- Replica 2: `postgresql://mmuser:mmuser_password@localhost:5434/mattermost`