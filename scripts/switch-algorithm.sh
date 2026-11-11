#!/usr/bin/env bash
set -e

# Script para alternar o algoritmo do Balanceador de Carga PHP em tempo real
# Uso: ./scripts/switch-algorithm.sh [round_robin|random|status]

ACTION=${1:-""}
CONTAINER_NAME="load_balancer"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Erro: O container '${CONTAINER_NAME}' não está em execução."
    exit 1
fi

show_status() {
    echo "======================================================"
    echo " Algoritmo atualmente ativo no Balanceador PHP:"
    echo "======================================================"
    CURRENT=$(docker exec "${CONTAINER_NAME}" cat /tmp/lb_algorithm.txt 2>/dev/null || echo "round_robin")
    echo " -> $CURRENT"
    echo "======================================================"
}

if [[ "$ACTION" == "status" ]]; then
    show_status
    exit 0
fi

if [[ "$ACTION" != "round_robin" && "$ACTION" != "round-robin" && "$ACTION" != "random" ]]; then
    echo "Uso: $0 [round_robin|random|status]"
    echo ""
    echo "Algoritmos disponíveis:"
    echo "  round_robin - Distribuição sequencial uniforme (modular)"
    echo "  random      - Sorteio aleatório de servidores"
    echo "  status      - Mostra o algoritmo ativo"
    echo ""
    show_status
    exit 1
fi

TARGET_ALGO="$ACTION"
if [[ "$TARGET_ALGO" == "round-robin" ]]; then
    TARGET_ALGO="round_robin"
fi

# Define o algoritmo no container
docker exec "${CONTAINER_NAME}" sh -c "echo '$TARGET_ALGO' > /tmp/lb_algorithm.txt"

echo ""
echo " Algoritmo alterado com sucesso para: $TARGET_ALGO"
show_status
