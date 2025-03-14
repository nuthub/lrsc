ifeq (, $(shell which docker 2>/dev/null))
  $(error "No docker found in PATH!")
endif

include .env

DOCKER_COMPOSE_AVAILABLE := $(shell docker compose version >/dev/null 2>&1 && echo yes || echo no)

ifeq ($(DOCKER_COMPOSE_AVAILABLE),yes)
  COMPOSE_CMD = docker compose
else
  COMPOSE_CMD = docker-compose
endif

ENV ?= dev

COMPOSE_FILES = -f docker-compose.yml -f docker-compose.$(ENV).yml
ALL_PROFILES = --profile all
LL_API_EXEC = $(GLOBAL_COMPOSE_CMD) exec api node cli/dist/server

.PHONY: build up down logs

GLOBAL_COMPOSE_CMD = $(COMPOSE_CMD) $(COMPOSE_FILES)

build:
	$(GLOBAL_COMPOSE_CMD) $(ALL_PROFILES) build

up:
	$(GLOBAL_COMPOSE_CMD) $(ALL_PROFILES) up -d

down:
	$(GLOBAL_COMPOSE_CMD) $(ALL_PROFILES) down

logs:
	$(GLOBAL_COMPOSE_CMD) $(ALL_PROFILES) logs -f

ll-create-admin:
	$(LL_API_EXEC) createSiteAdmin "${LL_MASTER_EMAIL}" "${LL_ORGANIZATION_NAME}" "${LL_MASTER_PASSWORD}"

ll-disable-register:
	$(LL_API_EXEC) disableRegister

ll-init: ll-create-admin ll-disable-register
