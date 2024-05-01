# CS Repro Mattermost

(Customer Success Repro Mattermost, although Colton Shaw Repro sounds cooler.)

This is designed to be used as a reproduction of a standard customer production environment. You'll find preconfigured SAML, LDAP, Advanced Logging, Prometheus, Grafana, Elasticsearch, and read replicas. 

- [LDAP](#ldap)
- [Commands](#commands)
- [Accounts](#accounts)
- [Grafana](#grafana)
- [mitmproxy](#mitmproxy)
- [Guides](#guides)
  - [How to upgrade](#how-to-upgrade)
  - [How to Downgrade](#how-to-downgrade)
  - [Migrating to Config in DB](#using-config-in-db)
  - [MMCTL](#mmctl)
  - [Adding Postgres Read Replicas](#adding-postgres-read-replicas)
- [Calls](#calls)

## Getting Started

1. Add an enterprise license to this folder with the name `license.mattermost`
  
    note: If you ignore this step Mattermost will not spin up.

2. Start the docker containers.

    You'll be prompted on setting up the test data.

    ```make
    make run
    ```

3. (Optional) If you want to start more features you can run one of the below.

    - `make run-db-replicas` - Adding the database replicas. Note this can take 2-3 minutes to spin up.
    - `make run-mm-replicas` - Adding a Mattermost HA node
    - `make run-all` - DB replicas and HA Mattermost.

4. Sign into Mattermost

    - You can use any of the accounts to sign in.
    - The keycloak container can be **very** picky sometimes and require a restart of just that container to sign in with that method the first time.

5. To stop everything run `make stop`.

6. To then bring it up again, without creating new containers, run `make start`. 

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

## Making Changes

If you're testing changes with Mattermost I do not suggest running `make restart` or `make stop` because the keycloak instance can quickly get into a failed state with too frequent of restarts. Instead do `make restart-mattermost`.

Additionally, the keycloak container can take up to 5 minutes to spin up. If it's taking a while with no logs output, just restart the keycloak container **only**.

## Commands

- **`make start`**: Starts the containers that already exist, nothing more.
- **`make run`**: Initializes the environment and creates the containers
- **`make run-all`**: Spins up all environment containers with the database replicas and Mattermost HA.
- You must run `make run` before running the below:
  - **`make run-db-replica`**: Launches the environment with replicas. Ideal for adding replicas to an existing setup or initializing with replicas from the get-go.
  - **`make run-mm-replica`**: Launches an additional Mattermost node and enables HA.
  - **`make run-rtcd`**: Launches the RTCD service for Mattermost Calls and updates the config to use it correctly.
- **`make backup-keycloak`**: Generates a backup of the current Keycloak setup in the files directory. Useful for infrequent backups.
- **`make restore-keycloak`**: Restores Keycloak data from an existing backup. Ensure `./volumes/keycloak` is cleared before restoration.
- **`make stop`**: Halts all running containers.
- **`make restart`**: Restarts all Docker containers in the environment.
- **`make restart-mattermost`**: Specifically restarts only the Mattermost containers for quick testing.
- **`make reset`**: Cleans the volumes directory and reinitializes the environment to default settings.
- **`make delete-data`**: Clears all data within volumes, effectively stopping Mattermost.
- **`make nuke`**: Erases all configurations and data, sparing your personal data.
- **`make nuke-rmi`**: Additionally removes all Docker images used by the environment, making it a complete cleanup.

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

### Using Config in DB

Config in DB has intentionally not been enabled by default to allow you to edit the `config.json` file directly for faster repros. However, if you want to migrate to config in DB just follow the below.

1. Start the container and init the default data. `make start`... `y`.

2. Edit the `docker-compose.yml`

    ```diff
      mattermost:
        environment:
          - MM_SqlSettings_DriverName=postgres
          - MM_SqlSettings_DataSource=postgres://mmuser:mmuser_password@cs-repro-postgres:5432/mattermost?sslmode=disable&connect_timeout=10&binary_parameters=yes
          - MM_SAMLSETTINGS_IDPCERTIFICATEFILE=/mattermost/config/saml-cert.crt
          # - MM_SqlSettings_DriverName=mysql
          # - MM_SqlSettings_DataSource=mmuser:mmuser_password@tcp(mysql:3306)/mattermost?charset=utf8mb4,utf8&writeTimeout=30s
          - MM_ServiceSettings_EnableLocalMode=true
          - MM_ServiceSettings_LocalModeSocketLocation=/var/tmp/mattermost_local.socket
          - MM_ServiceSettings_LicenseFileLocation=/mattermost/config/license.mattermost-enterprise
          ## Disable this to migrate your config to the database
    -#     - MM_CONFIG=postgres://mmuser:mmuser_password@cs-repro-postgres:5432/mattermost?sslmode=disable&connect_timeout=10&binary_parameters=yes
    +      - MM_CONFIG=postgres://mmuser:mmuser_password@cs-repro-postgres:5432/mattermost?sslmode=disable&connect_timeout=10&binary_parameters=yes
    ```

3. Move the config to the DB

    ```bash
    docker exec -it cs-repro-mattermost mmctl config migrate ./config/config.json "postgres://mmuser:mmuser_password@cs-repro-postgres:5432/mattermost?sslmode=disable&connect_timeout=10&binary_parameters=yes" --local
    ```

4. Restart Mattermost with a force stop / start to pickup the new env vars

    ```bash
    make stop
    make start
    ```

### MMCTL

To use `mmctl` it's already setup for local, just run the below docker command.

```bash
docker exec -it cs-repro-mattermost mmctl user list --local
```

### Adding Postgres Read Replicas

The basic structure for you to add two read replicas has been included in the repo already. This will take 2-5 minutes to get the replication setup, based on how much data you have in the database right now.

If you are starting from fresh run:

```bash
make run
make run-db-replicas
```

If you want to add replicas to an existing cs repro:

```bash
make run-db-replicas
```

#### Replication Config and access

All replica config files can be found in `./files/postgres/replica`. You can edit the `replica_x.conf` file to edit the specific configuration for a replica. You will need to restart the replicas once down, easiest way is `make stop && make start`

You can access each replica with the same username / password. Just need to change the port. Here's the output when using `postgresql`. Note if you use this in the mattermost config you need to replace `postgresql` to `postgres`.

- primary - `postgresql://mmuser:mmuser_password@localhost:5432/mattermost`
- replica_1 - `postgresql://mmuser:mmuser_password@localhost:5433/mattermost`
- replica_2 - `postgresql://mmuser:mmuser_password@localhost:5434/mattermost`

### Mattermost HA

Mattermost HA functionality is built into this repo already, but can be expanded out as needed. To use HA or add to an existing deployment you simply have to do:

```bash
make run
make run-mm-replicas
```

This runs mattermost on two ports that are connected on the backend.

- `localhost:8065`
- `localhost:8066`

## Grafana

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
  -f /ldap/addUsers.ldif
```

### Adding Group Members

To add a group member we have to use `ldapmodify`. Below is an example of the command. If you run the example we take the two user from the above command and add them to the `robot_mafia` group.

```bash
docker exec -it cs-repro-openldap ldapmodify \
  -x \
  -H ldap://openldap:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w GoodNewsEveryone \
  -f /ldap/addToGroup.ldif
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

## Calls

By default this is setup to run on the built in Mattermost calls. You can enable the `rtcd` service by running `make run-rtcd`, which will start up `rtcd` and adjust the settings within Mattermost to work. 

## mitmproxy

All traffic is routed through the mitmproxy for monitoring. You can access this with `localhost:8181` in your browser.

To disable this you can comment out the `HTTP_PROXY` and `HTTPS_PROXY` env vars on the Mattermost objects.