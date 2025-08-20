SHELL := /bin/bash

build:
	docker compose build --no-cache

up:
	docker compose up -d

down:
	docker compose down

scan:
	bash scripts/scan.sh

patch:
	bash scripts/patch.sh

rebuild: down build up

logs:
	docker compose logs -f app
