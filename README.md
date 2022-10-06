# README

This is a docker compose file that contains a working Mattermost with an LDAP server. The LDAP image comes from [rroemhild/docker-test-openldap](https://github.com/rroemhild/docker-test-openldap).

To start this docker file run the below from the root repo directory



You can access mattermost via `localhost:8065`.

## Getting Started

1. Add an enterprise license to this folder with the name `license.txt`

2. Start the docker containers. This may take a second to download everything. 

```
docker-compose up -d
```

3. You can log access Mattermost at `localhost:8065`


## Things to break

- User left an ldap synced team of their own accord
- new email address, can't sign in
- ID attributes don't match.



## Make key

```bash

openssl req -x509 -newkey rsa:4096 -keyout myKey.pem -out cert.pem -days 365 -nodes
openssl pkcs12 -export -out keyStore.p12 -inkey myKey.pem -in cert.pem
```