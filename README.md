# README

This is a basic reproduction that includes various components preconfigured like SAML, LDAP, advanced logging, prometheus, grafana, and elasticsearch.

## Making Changes

If you're testing changes with Mattermost I do not suggest running `docker compose restart` or `docker compose down / up` because the keycloak instance can quickly get into a failed state with too frequent of restarts. Instead do `docker down mattermost`. Additionally, the keycloak container can take up to 5 minutes to spin up. If it's taking a while with no logs output, just restart the keycloak container **only**.

## Getting Started

1. Add an enterprise license to this folder with the name `license.txt`
  note: If you ignore this set Mattermost will not spin up.

2. Start the docker containers. This may take a second to download everything. 

  If you don't want to watch the logs use the below:
  ```
  docker-compose up -d
  // OR
  docker compose up -d // for docker desktop
  ```

  If you want to watch the logs start up with

  ```bash
  docker-compose up
  // OR
  docker compose up // for docker desktop
  ```

3. Sign into Mattermost
  - You can use any of the accounts to sign in.
  - The keycloak container can be **very** picky sometimes and require a restart of just that container to sign in with that method the first time.

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
