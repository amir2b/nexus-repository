#!/usr/bin/env make

all: down up logs

init:
	cp -n .env.example .env
	nano .env

build:
	docker compose build

up: .env
	docker compose up --detach

down: .env
	# docker compose down --remove-orphans --volumes
	docker compose down --remove-orphans

pull:
	docker compose pull

logs:
	docker compose logs -f
