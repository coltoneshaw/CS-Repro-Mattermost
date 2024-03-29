# README

This is a basic reproduction that includes various components preconfigured like SAML, LDAP, advanced logging, prometheus, grafana, and elasticsearch.

- [LDAP](#ldap)
- [MMCTL](#mmctl)

## Making Changes

If you're testing changes with Mattermost I do not suggest running `make restart` or `make stop` because the keycloak instance can quickly get into a failed state with too frequent of restarts. Instead do `make restart-mattermost`. 

Additionally, the keycloak container can take up to 5 minutes to spin up. If it's taking a while with no logs output, just restart the keycloak container **only**.

## Getting Started

1. Add an enterprise license to this folder with the name `license.mattermost`
  note: If you ignore this step Mattermost will not spin up.

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

This takes your existing keycloak setup and backs it up in the files directory. You most likely don't need this frequently.

### `make restore-keycloak`

If you made changes to keycloak, this will copy over the keycloak data. You'll want to delete the `./volumes/keycloak` first.

### `make stop`

Simply stops the running containers.

### `make restart`

Simply restarts the docker containers.

### `make restart-mattermost`

Restarts only the Mattermost containers.

### `make reset`

This deletes the volumes directory and starts everything again. Easiest way to get the environment back the default.

### `make delete-data`

This clears all data from the volumes and stops Mattermost.

### `make nuke`

Destroys everything (Except your life). 

### `make nuke-rmi`

Destroys everything, and removes the docker images used. 

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

  You're just replacing the tag at the end, this one is `7.7` for example. It must be a version of Mattermost that exists on Docker.

  ```bash
  mattermost/mattermost-enterprise-edition:release-7.7
  ```

2. Run `make restart-mattermost`

  This will bounce the Mattermost container only.

### How to Downgrade

Doing this will wipe anything you have in the database and any existing Mattermost config. If you desire to manually downgrade, follow the upgrade steps but in reverse. Note you might have some issues with the patch config and such.

1. Modify the line in the `docker-compose.yml` file to be the version you want

  You're just replacing the tag at the end, this one is `7.7` for example. It must be a version of Mattermost that exists on Docker.

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


## LDAP

### Adding Users

You can easily add users to the ldap container by using the provided ldif file and query.

Here is an example of the command. If you run this right now you'll add two users to your ldap environment.
Note that if the data already exists in the ldif the command will fail.

```bash
docker exec -it cs-repro-openldap ldapmodify \
  -x \
  -H ldap://openldap:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w GoodNewsEveryone \
  -f /ldap/ldapadd.ldif
```

### Adding Group Members

To add a group member we have to use `ldapmodify`. Below is an example of the command. If you run the example we take the two user from the above command and add them to the `robot_mafia` group.

```bash
docker exec -it cs-repro-openldap ldapmodify \
  -x \
  -H ldap://openldap:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w GoodNewsEveryone \
  -f /ldap/ldapmodify.ldif
```

### LDAP Search

Everything that comes after the `-w` flag is a part of the search on the base DN. Just replace that with what you have in the user filter. 

#### Searching for Groups

```bash
docker exec -it cs-repro-openldap ldapsearch \
  -x -b "DC=planetexpress,DC=com" \
  -H ldap://openldap:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w GoodNewsEveryone \
  "(objectClass=Group)"
```

#### Searching for People

```bash
docker exec -it cs-repro-openldap ldapsearch \
  -x -b "DC=planetexpress,DC=com" \
  -H ldap://openldap:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w GoodNewsEveryone \
  "(objectClass=Person)"
```

### Add New Attributes to LDAP

Let's say you need a special attribute added to LDAP for testing, like a uniqueID you can tweak. Using the below command we'll add an attribute called `uniqueID` to our users from above. If we want to extend this to the rest of Futurama they'll need to be in the ldif file. 

```bash
docker exec -it cs-repro-openldap ldapmodify \
  -x \
  -H ldap://openldap:10389 \
  -D "cn=admin,cn=config" \
  -w GoodNewsEveryone \
  -f /ldap/addUniqueID.ldif
```

A few notes, when adding this attribute you must add the `customPerson` objectclass to the person before you can assign the attribute. See the `ldapadd.ldif` file for help. 

Now that you've added the Id to the environment, you have to add it to the users.

```bash
docker exec -it cs-repro-openldap ldapmodify \
  -x \
  -H ldap://openldap:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w GoodNewsEveryone \
  -f /ldap/addUniqueIdToUsers.ldif
```

## MMCTL

To use `mmctl` it's already setup for local, just run the below docker command.

```bash
docker exec -it cs-repro-mattermost mmctl user list --localhost
```