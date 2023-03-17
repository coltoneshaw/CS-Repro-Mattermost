#!/bin/bash

logins () {
  echo ===========================================================
  echo
  echo "- Mattermost: http://localhost:8065" with the logins above if you ran setup
  echo "- Keycloak: http://localhost:8080" with 'admin' / 'admin'
  echo "- Grafana: http://localhost:3000" with 'admin' / 'admin'
  echo "    - All Mattermost Grafana charts are setup."
  echo "    - For more info https://github.com/coltoneshaw/CS-Repro-Mattermost#use-grafana"
  echo "- Prometheus: http://localhost:9090"
  echo "- PostgreSQL"  "localhost:5432" with 'mmuser' / 'mmuser_password'
  echo
  echo ===========================================================
}

"$@"