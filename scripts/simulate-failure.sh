#!/usr/bin/env bash
set -e

# Script de Simulação de Falhas e Tolerância a Quedas (Failover)
# Demonstra o comportamento do Balanceador PHP feito do zero ao derrubar instâncias

TARGET_CONTAINER="app_server2"
LB_URL="http://localhost:8080/"
NUM_REQUESTS=10

trap 'echo ""; echo "Garantindo que $TARGET_CONTAINER esteja em execução..."; docker start "$TARGET_CONTAINER" > /dev/null 2>&1 || true' EXIT

echo "======================================================"
echo "    SIMULAÇÃO DE FALHAS - BALANCEADOR PHP DO ZERO     "
echo "======================================================"
echo ""

# 1. Estado inicial: todas as 3 instâncias ativas
echo " [Fase 1] Verificando distribuição inicial (3 instâncias ativas):"
for i in $(seq 1 $NUM_REQUESTS); do
    INST=$(curl -sI "$LB_URL" | grep "X-Backend-Server:" | awk '{print $2}' | tr -d '\r')
    echo "  Requisição #$i -> Atendida por: ${INST:-ERRO}"
    sleep 0.2
done
echo ""

# 2. Simulando falha do app_server2
echo " [Fase 2] SIMULANDO FALHA: Derrubando container '$TARGET_CONTAINER'..."
docker stop "$TARGET_CONTAINER" > /dev/null
echo "   Container '$TARGET_CONTAINER' parado com sucesso!"
echo ""

# 3. Testando comportamento com o servidor fora do ar
echo " [Fase 3] Enviando requisições com '$TARGET_CONTAINER' FORA DO AR:"
echo "   (O código do load_balancer/index.php detecta o erro e tenta o próximo nó)"
echo ""
FAILURES=0
for i in $(seq 1 $NUM_REQUESTS); do
    RAW_RES=$(curl -sI --max-time 4 "$LB_URL" || true)
    HTTP_CODE=$(echo "$RAW_RES" | grep "^HTTP/" | tail -n1 | awk '{print $2}')
    INST=$(echo "$RAW_RES" | grep "X-Backend-Server:" | awk '{print $2}' | tr -d '\r')

    if [[ "$HTTP_CODE" == "200" ]]; then
        echo "  Requisição #$i [HTTP $HTTP_CODE] -> Atendida por: $INST (Failover com Sucesso!)"
    else
        echo "  Requisição #$i [HTTP ${HTTP_CODE:-FALHA}] -> FALHA NA REQUISIÇÃO"
        FAILURES=$((FAILURES + 1))
    fi
    sleep 0.2
done

echo ""
if [[ $FAILURES -eq 0 ]]; then
    echo " RESULTADO DO TESTE: 100% de sucesso! Nenhuma requisição perdida durante a falha."
else
    echo "  RESULTADO DO TESTE: $FAILURES requisições falharam."
fi
echo ""

# 4. Recuperação do servidor
echo " [Fase 4] RECUPERAÇÃO: Reiniciando container '$TARGET_CONTAINER'..."
docker start "$TARGET_CONTAINER" > /dev/null
echo "   Aguardando 2 segundos para o container subir..."
sleep 2
echo ""

# 5. Verificando reintegração
echo " [Fase 5] Verificando reintegração automática de '$TARGET_CONTAINER' ao cluster:"
for i in $(seq 1 $NUM_REQUESTS); do
    INST=$(curl -sI "$LB_URL" | grep "X-Backend-Server:" | awk '{print $2}' | tr -d '\r')
    echo "  Requisição #$i -> Atendida por: ${INST:-ERRO}"
    sleep 0.2
done

echo ""
echo "======================================================"
echo "    SIMULAÇÃO DE FALHA CONCLUÍDA COM SUCESSO!         "
echo "======================================================"
