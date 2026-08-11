DOCKER_COMPOSE := docker compose
ENV ?= dev
DOCKER_COMPOSE_FILE := $(if $(filter prod,$(ENV)),-f docker-compose.prod.yml,-f docker-compose.yml)
DOCKER_COMPOSE_CMD := $(DOCKER_COMPOSE) $(DOCKER_COMPOSE_FILE)
API_SERVICE := api
MIGRATE_SERVICE := migrate

.DEFAULT_GOAL := help

.PHONY: up build build_no_cache down down_volumes stop exec shell logs ps reup check test smoke routes migrate current history versions help

## -----------------------------
## Base Commands
## -----------------------------

up:
	@chmod +x ./entrypoint.sh
	$(DOCKER_COMPOSE_CMD) up -d

build:
	@chmod +x ./entrypoint.sh
	$(DOCKER_COMPOSE_CMD) build

build_no_cache:
	@chmod +x ./entrypoint.sh
	$(DOCKER_COMPOSE_CMD) build --no-cache

down:
	$(DOCKER_COMPOSE_CMD) down

down_volumes:
	$(DOCKER_COMPOSE_CMD) down -v

stop:
	$(DOCKER_COMPOSE_CMD) stop

exec:
	$(DOCKER_COMPOSE_CMD) exec $(API_SERVICE) bash

shell:
	$(DOCKER_COMPOSE_CMD) run --rm $(API_SERVICE) bash

logs:
	$(DOCKER_COMPOSE_CMD) logs -f $(API_SERVICE)

ps:
	$(DOCKER_COMPOSE_CMD) ps

reup: down up

check:
	$(DOCKER_COMPOSE_CMD) run --rm $(API_SERVICE) julia --project=. -e 'using Pkg; Pkg.instantiate(); using Genie; Genie.loadapp()'

test:
	$(DOCKER_COMPOSE_CMD) run --rm $(API_SERVICE) julia --project=test test/runtests.jl

smoke:
	@for i in $$(seq 1 30); do \
		if $(DOCKER_COMPOSE_CMD) exec -T $(API_SERVICE) julia --project=. -e 'using HTTP; try response = HTTP.get("http://127.0.0.1:8000/health"; status_exception=false); print(String(response.body)); exit(response.status == 200 ? 0 : 1); catch; exit(1); end' ; then \
			exit 0; \
		fi; \
		echo "Waiting for API... ($$i/30)"; \
		sleep 2; \
	done; \
	exit 1

routes:
	$(DOCKER_COMPOSE_CMD) run --rm $(API_SERVICE) julia --project=. -e 'using Pkg; Pkg.instantiate(); using Genie; Genie.loadapp(); println("GET /health"); println("POST /api/auth/signup"); println("POST /api/auth/login"); println("POST /api/auth/refresh"); println("POST /api/auth/logout"); println("POST /api/auth/forgot-password"); println("GET /api/auth/reset-password/verify"); println("POST /api/auth/reset-password"); println("GET /api/accounts"); println("POST /api/accounts"); println("GET /api/accounts/me"); println("PUT /api/accounts/me/password"); println("PUT /api/accounts/:target_account_id::Int/disable"); println("PUT /api/accounts/:target_account_id::Int/enable"); println("GET /api/accounts/:target_account_id::Int"); println("PUT /api/accounts/:target_account_id::Int")'

migrate:
	$(DOCKER_COMPOSE_CMD) run --rm $(MIGRATE_SERVICE)

current:
	$(DOCKER_COMPOSE_CMD) run --rm $(MIGRATE_SERVICE) julia --project=. -e 'using Pkg; Pkg.instantiate(); using Genie; Genie.loadapp(); using SearchLight; SearchLight.Migration.status()'

history:
	$(DOCKER_COMPOSE_CMD) run --rm $(MIGRATE_SERVICE) julia --project=. -e 'using Pkg; Pkg.instantiate(); using Genie; Genie.loadapp(); using SearchLight; SearchLight.Migration.status()'

versions:
	$(DOCKER_COMPOSE_CMD) run --rm $(API_SERVICE) julia --project=. -e 'using Pkg; Pkg.instantiate(); using Genie; println("Julia ", VERSION); println("Genie ", Pkg.dependencies()[Base.UUID("c43c736e-a2d1-11e8-161f-af95117fbd1e")].version)'

## -----------------------------
## Help
## -----------------------------

help:
	@echo "Usage: make [target] [ENV=dev|prod]"
	@echo "All targets run through Docker. Local Julia/Node is not required."
	@echo ""
	@echo "Targets:"
	@echo "  up              Start containers (default: dev)"
	@echo "  build           Build containers"
	@echo "  build_no_cache  Build containers without cache"
	@echo "  down            Stop and remove containers and networks"
	@echo "  down_volumes    Stop and remove containers, networks, and volumes"
	@echo "  stop            Stop containers"
	@echo "  exec            Enter api container shell"
	@echo "  shell           Start a one-off api shell"
	@echo "  logs            Show api logs"
	@echo "  ps              Show container status"
	@echo "  reup            Restart environment (down + up)"
	@echo "  check           Load Genie app inside the api container"
	@echo "  test            Run tests inside the api container"
	@echo "  smoke           Call /health from the running api container"
	@echo "  routes          Print route paths"
	@echo "  migrate         Run database migrations"
	@echo "  current         Show migration status"
	@echo "  history         Show migration status"
	@echo "  versions        Print Julia and Genie versions"
