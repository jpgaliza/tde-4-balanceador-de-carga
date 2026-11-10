#!/usr/bin/env bash
set -e

# Script para alternar o algoritmo de balanceamento de carga no Nginx em tempo real
# Uso: ./scripts/switch-algorithm.sh [round-robin|least-conn|status]

ACTION=${1:-""}

CONTAINER_NAME="nginx_lb"

# Verifica se o container está em execução
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Erro: O container '${CONTAINER_NAME}' não está em execução."
    echo "Execute 'docker compose up -d' primeiro."
    exit 1
fi

show_status() {
    echo "======================================================"
    echo " Configuração ativa do Upstream no Nginx:"
    echo "======================================================"
    docker exec "${CONTAINER_NAME}" cat /etc/nginx/conf.d/upstream.conf
    echo "======================================================"
}

if [[ "$ACTION" == "status" ]]; then
    show_status
    exit 0
fi

if [[ "$ACTION" != "round-robin" && "$ACTION" != "least-conn" ]]; then
    echo "Uso: $0 [round-robin|least-conn|status]"
    echo ""
    echo "Opções disponíveis:"
    echo "  round-robin - Distribuição sequencial uniforme entre as instâncias"
    echo "  least-conn  - Direciona requisições para a instância com menor número de conexões ativas"
    echo "  status      - Exibe o arquivo de upstream atualmente ativo"
    echo ""
    show_status
    exit 1
fi

echo "======================================================"
echo " Alterando algoritmo de balanceamento para: $ACTION"
echo "======================================================"

# Copia a configuração do algoritmo escolhido para upstream.conf dentro do container
docker exec "${CONTAINER_NAME}" cp "/etc/nginx/algorithms/${ACTION}.conf" /etc/nginx/conf.d/upstream.conf

# Valida a sintaxe da configuração
echo "Testando sintaxe da configuração do Nginx..."
docker exec "${CONTAINER_NAME}" nginx -t

# Recarrega o Nginx sem derrubar conexões ativas (zero downtime)
echo "Recarregando processo mestre do Nginx (reload)..."
docker exec "${CONTAINER_NAME}" nginx -s reload

echo ""
echo " Algoritmo alterado com sucesso para: $ACTION!"
echo "======================================================"
show_status
