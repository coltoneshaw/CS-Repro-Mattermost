#!/bin/bash

DIR="./volumes/keycloak"

restore () {
  if [ -d "$DIR" ]; then
    echo ===========================================================
    echo 
    echo "'$DIR' found skipping keycloak setup"
    echo
    echo ===========================================================
  else
    echo ===========================================================
    echo 
    echo "Warning: '$DIR' NOT found. Setting up from base"
    echo
    echo ===========================================================
    mkdir -p ./volumes/keycloak
    tar -zxf ./files/keycloak/keycloakBackup.tar -C ./volumes/keycloak
  fi
}

backup () {
  if [ -d "$DIR" ]; then
    echo ===========================================================
    echo 
    echo "'$DIR' found backing up keycloak"
    echo
    echo ===========================================================

    tar -zcf keycloakBackup.tar -C ./volumes/keycloak . 
	  mv keycloakBackup.tar ./files/keycloak/keycloakBackup.tar

  else
    echo ===========================================================
    echo 
    echo "Warning: '$DIR' NOT found. Skipping backup"
    echo
    echo ===========================================================
  fi
  
}

"$@"