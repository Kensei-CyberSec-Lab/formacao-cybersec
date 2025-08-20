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

python-fix:
	bash scripts/python-fix.sh

rebuild: down build up

logs:
	docker compose logs -f app
