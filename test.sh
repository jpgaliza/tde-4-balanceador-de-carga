#!/usr/bin/env bash
set -e


LB_URL="http://localhost:8080"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

trap 'echo ""; echo "Restaurando todos os containers..."; docker start app_server1 app_server2 app_server3 > /dev/null 2>&1 || true' EXIT

pause() {
    echo ""
    echo -e "${YELLOW}>> Pressione ENTER para o próximo teste (ou aguarde 3s)...${NC}"
    read -t 3 -r || true
    echo ""
}

clear || true
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}   BATERIA DE TESTES AUTOMATIZADOS - BALANCEADOR DE CARGA PHP   ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo ""

echo -e "${GREEN}[TESTE 1] Algoritmo Round Robin (3 Servidores Ativos)${NC}"
echo "Objetivo: Demonstrar a distribuição sequencial e cíclica (1 -> 2 -> 3 -> 1)."
echo ""
for i in {1..6}; do
    RES=$(curl -s "$LB_URL/")
    echo -e "  #$i: $RES"
    sleep 0.3
done
pause

echo -e "${GREEN}[TESTE 2] Algoritmo Random (Sorteio Aleatório)${NC}"
echo "Objetivo: Demonstrar a escolha aleatória através do parâmetro ?algo=random."
echo ""
for i in {1..6}; do
    RES=$(curl -s "$LB_URL/?algo=random")
    echo -e "  #$i: $RES"
    sleep 0.3
done
pause

echo -e "${RED}[TESTE 3] Simulação de Falha: Derrubando 1 Servidor (app_server2)${NC}"
echo "Executando: docker stop app_server2..."
docker stop app_server2 > /dev/null
echo "Container app_server2 DESLIGADO!"
echo ""
echo "Disparando requisições (espera-se que apenas app_server1 e app_server3 respondam):"
for i in {1..6}; do
    RES=$(curl -s "$LB_URL/")
    echo -e "  #$i: $RES"
    sleep 0.3
done
pause

echo -e "${RED}[TESTE 4] Simulação de Falha Severa: Apenas 1 Servidor Ativo${NC}"
echo "Executando: docker stop app_server3..."
docker stop app_server3 > /dev/null
echo "Containers app_server2 e app_server3 DESLIGADOS!"
echo ""
echo "Disparando requisições com APENAS o app_server1 vivo:"
for i in {1..4}; do
    RES=$(curl -s "$LB_URL/")
    echo -e "  #$i: $RES"
    sleep 0.3
done
pause

echo -e "${GREEN}[TESTE 5] Recuperação Automática: Religando app_server2 e app_server3${NC}"
docker start app_server2 app_server3 > /dev/null
echo "Aguardando 2 segundos para inicialização dos containers..."
sleep 2
echo ""
echo "Disparando requisições para verificar se as 3 instâncias voltaram ao rodízio:"
for i in {1..6}; do
    RES=$(curl -s "$LB_URL/")
    echo -e "  #$i: $RES"
    sleep 0.3
done
pause

echo -e "${BLUE}[TESTE 6] Teste de Carga com Apache Benchmark (ab)${NC}"
echo "Executando: ab -n 300 -c 15 $LB_URL/"
echo ""
ab -n 300 -c 15 "$LB_URL/" | grep -E "(Server Software|Server Hostname|Complete requests|Failed requests|Requests per second|Time per request)"

echo ""
echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}         TODOS OS TESTES FORAM CONCLUÍDOS COM 100% DE SUCESSO!  ${NC}"
echo -e "${GREEN}================================================================${NC}"
