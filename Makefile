#!/usr/bin/env make

all: down up logs

up: .env
	docker compose up --detach

build:
	docker compose build

down: .env
	docker compose down --remove-orphans --volumes

logs:
	docker compose logs -f
