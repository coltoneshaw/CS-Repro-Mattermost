.PHONY: stop start check_mattermost
	
logs:
	@echo "Following logs..."
	@docker-compose logs --follow
	@echo "Done"

setup-mattermost:
	@./scripts/mattermost.sh setup

check-mattermost:
	@./scripts/mattermost.sh waitForStart

backup-keycloak:
	@./scripts/keycloak.sh backup

restore-keycloak:
	@./scripts/keycloak.sh restore

echo-logins:
	@./scripts/general.sh logins

run: 
	@echo "Starting..."
	@make restore-keycloak
	@make run-core
	@make setup-mattermost
	@make echo-logins

run-core:
	@echo "Starting the core services... hang in there."
	@docker-compose up -d postgres openldap prometheus grafana elasticsearch mattermost keycloak

run-db-replicas:
	@echo "Starting with replicas. Hang in there..."
	@docker-compose up -d postgres-replica-1 postgres-replica-2
	@docker exec -it cs-repro-mattermost mmctl config patch /mattermost/config/replicaConfig.json --local
	@echo "Should be up and running. Go crazy."

## Need a way to modify the 
run-mm-replicas:
	@echo "Starting Mattermost replicas. Hang in there..."
	@docker exec -it cs-repro-mattermost mmctl config set ClusterSettings.Enable true --local
	@docker-compose down mattermost
	@docker-compose up -d mattermost mattermost-2
	@echo "Should be up and running. Go crazy."

run-all: run run-db-replicas run-mm-replicas

stop:
	@echo "Stopping..."
	@docker-compose stop
	@echo "Done"

restart:
	@docker-compose restart
	@make check-mattermost

restart-mattermost:
	@echo "Stopping Mattermost container"
	@docker stop cs-repro-mattermost
	@wait
	@echo "Starting Mattermost container"
	@docker start cs-repro-mattermost
	@make check-mattermost

reset:
	@echo "Resetting..."
	@make delete-data
	@make start

downgrade:
	@echo "Downgrading Mattermost..."
	@docker stop cs-repro-mattermost || true && docker rm cs-repro-mattermost || true
	@docker stop cs-repro-postgres || true && docker rm cs-repro-postgres || true
	rm -rf ./volumes/mattermost
	rm -rf ./volumes/db
	docker-compose up -d
	@make setup-mattermost

delete-dockerfiles:
	@echo "Deleting data..."
	@docker-compose rm
	@rm -rf ./volumes
	@rm -rf ./files/postgres/replica/replica_*
	@echo "Done"

delete-data: stop delete-dockerfiles

nuke: 
	@echo "Nuking Docker..."
	@docker-compose down --volumes --remove-orphans
	@make delete-data

nuke-rmi: 
	@echo "Nuking Docker with images..."
	@docker-compose down --rmi all --volumes --remove-orphans
	@make delete-data
