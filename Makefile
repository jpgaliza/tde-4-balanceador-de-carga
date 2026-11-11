.PHONY: up down restart test logs status help

help:
	@echo "Comandos disponíveis:"
	@echo "  make up       - Sobe todos os containers (balanceador + 3 servidores)"
	@echo "  make down     - Desliga todos os containers"
	@echo "  make restart  - Reinicia o ambiente"
	@echo "  make test     - Roda a bateria completa de testes de apresentação"
	@echo "  make status   - Mostra o status dos containers"
	@echo "  make logs     - Acompanha os logs em tempo real"

up:
	docker compose up -d --build

down:
	docker compose down

restart:
	docker compose restart

test:
	@bash test.sh 2>/dev/null || powershell -ExecutionPolicy Bypass -File test.ps1

status:
	docker compose ps

logs:
	docker compose logs -f
