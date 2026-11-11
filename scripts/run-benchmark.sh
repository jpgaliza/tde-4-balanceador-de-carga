#!/usr/bin/env bash
set -e

# Script para Execução de Testes de Carga com Apache Benchmark (ab)
# Uso: ./scripts/run-benchmark.sh [requests] [concurrency] [algorithm]

REQUESTS=${1:-500}
CONCURRENCY=${2:-20}
TARGET_ALGO=${3:-"all"}
URL="http://localhost:8080/"
OUTPUT_FILE="benchmark_results.txt"

if ! command -v ab &> /dev/null; then
    echo "Erro: Apache Benchmark (ab) não foi encontrado no sistema."
    exit 1
fi

run_test() {
    local algo=$1
    echo "======================================================"
    echo " [TESTE DE CARGA] Balanceador PHP - Algoritmo: $algo"
    echo " Configuração: $REQUESTS requisições | $CONCURRENCY conexões simultâneas"
    echo " URL: $URL"
    echo "======================================================"

    ./scripts/switch-algorithm.sh "$algo" > /dev/null
    sleep 1

    local tmp_output
    tmp_output=$(mktemp)

    ab -n "$REQUESTS" -c "$CONCURRENCY" "$URL" > "$tmp_output" 2>&1

    local rps
    local latency
    local failed

    rps=$(grep "Requests per second:" "$tmp_output" | awk '{print $4}')
    latency=$(grep "Time per request:" "$tmp_output" | head -n1 | awk '{print $4}')
    failed=$(grep "Failed requests:" "$tmp_output" | awk '{print $3}')

    echo ""
    echo "--- Resultados ($algo) ---"
    echo "  Vazão (Throughput):    ${rps:-N/A} requisições/s"
    echo "  Latência média:        ${latency:-N/A} ms"
    echo "  Requisições com falha: ${failed:-0}"
    echo "--------------------------"
    echo ""

    rm -f "$tmp_output"
}

if [[ "$TARGET_ALGO" == "all" ]]; then
    run_test "round_robin"
    sleep 2
    run_test "random"
    ./scripts/switch-algorithm.sh round_robin > /dev/null
else
    run_test "$TARGET_ALGO"
fi
