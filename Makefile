.PHONY: stop start check_mattermost
	
docker_follow_logs:
	@echo "Following logs..."
	@docker compose logs --follow
	@echo "Done"


check_mattermost:

setup-mattermost:
	@./scripts/mattermost.sh setup

backup-keycloak:
	@./scripts/keycloak.sh backup

restore-keycloak:
	@./scripts/keycloak.sh restore

start: 
	@echo "Starting..."
	@make restore-keycloak
	@docker compose up -d
	@make setup-mattermost
	
stop:
	@echo "Stopping..."
	@docker compose down
	@echo "Done"

restart:
	@docker compose restart

reset:
	@echo "Resetting..."
	@make delete-data
	@make start

delete-dockerfiles:
	@echo "Deleting data..."
	@docker compose rm
	@rm -rf ./volumes
	@echo "Done"

delete-data: stop delete-dockerfiles

nuke: 
	@echo "Nuking Docker..."
	@docker compose down --rmi all --volumes --remove-orphans
	@make delete-data

