# README

This is a basic reproduction that includes various components preconfigured like SAML, LDAP, advanced logging, prometheus, grafana, and elasticsearch.

## Making Changes

If you're testing changes with Mattermost I do not suggest running `make restart` or `make stop` because the keycloak instance can quickly get into a failed state with too frequent of restarts. Instead do `make restart-mattermost`. 

Additionally, the keycloak container can take up to 5 minutes to spin up. If it's taking a while with no logs output, just restart the keycloak container **only**.

## Getting Started

1. Add an enterprise license to this folder with the name `license.mattermost`
  note: If you ignore this set Mattermost will not spin up.

2. Start the docker containers. This may take a second to download everything. 

  You'll be prompted on setting up the test data.

  ```make
  make start
  ```

3. Sign into Mattermost

  - You can use any of the accounts to sign in.
  - The keycloak container can be **very** picky sometimes and require a restart of just that container to sign in with that method the first time.

## Commands

### `make backup-keycloak`

This takes your exiting keycloak setup and backs it up in the files directory. You most likely don't need this frequently.

### `make restore-keycloak`

If you made changes to keycloak, this will copy over the keycloak data. You'll want to delete the `./volumes/keycloak` first.

### `make stop`

Simply stops the running contains

### `make restart`

Simply restarts the docker containers.

### `make restart-mattermost`

Restarts only the Mattermost containers.

### `make reset`

This deletes the volumes directory and starts everything again. Easiest way to get to get the environment back the default.

### `make delete-data`

This clears all data from the volumes and stops Mattermost.

### `make nuke`

Destroys everything (Except your life). 

## Accounts

| Username  | Password  | Keycloak Role | Mattermost Role | Can use LDAP? | Can use SAML? |
|-----------|-----------|---------------|-----------------|---------------|---------------|
| admin     | admin     | Admin         | n/a             | n/a           | n/a           |
| professor | professor | User          | Sys Admin       | Yes           | Yes           |
| bender    | bender    | User          | Member          | Yes           | Yes           |
| hermes    | hermes    | User          | Sys Admin       | Yes           | Yes           |
| fry       | fry       | User          | Member          | Yes           | Yes           |
| leela     | leela     | User          | Member          | Yes           | Yes           |
| zoidberg  | zoidberg  | User          | Member          | Yes           | Yes           |
| amy       | amy       | User          | Member          | Yes           | Yes           |

## Guides

### How to upgrade

1. Modify the line in the `docker-compose.yml` file to be the version you want

  You're just replacing the tag at the end, ths one is `7.7` for example. It must be a version of Mattermost that exists on Docker.

  ```bash
  mattermost/mattermost-enterprise-edition:release-7.7
  ```

2. Run `make restart-mattermost`

  This will bounce the Mattermost container only.

### How to Downgrade

Doing this will wipe anything you have in the database and any existing Mattermost config. If you desire to manually downgrade, follow the upgrade steps but in reverse. Note you might have some issues with the patch config and such.

1. Modify the line in the `docker-compose.yml` file to be the version you want

  You're just replacing the tag at the end, ths one is `7.7` for example. It must be a version of Mattermost that exists on Docker.

  ```bash
  mattermost/mattermost-enterprise-edition:release-7.7
  ```
  
2. Run `make downgrade`

  This will:

  - delete the database
  - Restart the database container
  - Restart the Mattermost container

## Use Grafana

All the Mattermost grafana charts are already installed and linked, you just have to access them. 

1. Go to `localhost:3000`
2. Sign in with `admin` / `admin`. Change the password if you want, I don't suggest it.
3. Click `Dashboards` > `Manage`
4. Click any of the dashboards you want to view. 