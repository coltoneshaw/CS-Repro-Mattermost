#!/bin/bash

DIR="./volumes/mattermost"

setup() {
  if ! waitForStart; then
    make stop
  else

    echo
    echo
    echo
    echo "Do you want to setup test data for Mattermost?"
    echo "This will overwrite some config and add a sysadmin user and a regular user."
    echo "If you are curious about the config changes check out the file ./files/mattermost/defaultConfig.json"
    echo "If you don't want to do this, just press enter."
    echo
    read -p "y / N   " -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo ===========================================================
      echo
      echo "setting up test Data for Mattermost"
      echo
      echo ===========================================================

      docker exec -it cs-repro-mattermost mmctl config patch /mattermost/config/defaultConfig.json --local
      docker exec -it cs-repro-mattermost mmctl user create --password Testpassword123! --username sysadmin --email sysadmin@example.com --system-admin --local
      docker exec -it cs-repro-mattermost mmctl user create --password Testpassword123! --username user-1 --email user-1@example.com --local

      echoLogins
      exit 0
    else 
      echo "skipping test Data setup for Mattermost"
      exit 0
    fi
  fi

  echo
  echo "Alright, everything seems to be setup and running. Enjoy."

}

total=0
max_wait_seconds=120

waitForStart() {
  echo "waiting $max_wait_seconds seconds for the server to start"

  while [[ "$total" -le "$max_wait_seconds" ]]; do
    if docker exec -i cs-repro-mattermost mmctl system status --local 2>/dev/null; then
      echo "server started"
      return 0
    else
      ((total = total + 1))
      printf "."
      sleep 1
    fi
  done

  printf "\nserver didn't start in $max_wait_seconds seconds\n"

  make stop
  exit 1
}

echoLogins() {
  echo
  echo ========================================================================
  echo
  echo "Mattermost logins:"
  echo
  echo "- System admin"
  echo "     - username: sysadmin"
  echo "     - password: Testpassword123!"
  echo "- Regular account:"
  echo "     - username: user-1"
  echo "     - password: Testpassword123!"
  echo "- LDAP or SAML account:"
  echo "     - username: professor"
  echo "     - password: professor"
  echo
  echo "For more logins check out https://github.com/coltoneshaw/CS-Repro-Mattermost#accounts"
  echo
  echo ========================================================================
}

upgrade() {
  sed -i "s#7.7#7.8#g" docker-compose.yml
  sed -i 's/release-.*/release-6.88/' docker-compose.yml

  sed -i '/release-.*/release-6.88/' ${PWD}/docker-compose.yml

}

"$@"
