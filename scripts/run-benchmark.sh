#!/usr/bin/env bash
set -e

# Script para Execução de Testes de Carga com Apache Benchmark (ab)
# Uso: ./scripts/run-benchmark.sh [requests] [concurrency] [algorithm] [path]
# Exemplo: ./scripts/run-benchmark.sh 1000 50 all /

REQUESTS=${1:-1000}
CONCURRENCY=${2:-50}
TARGET_ALGO=${3:-"all"} # round-robin, least-conn, all
ENDPOINT_PATH=${4:-"/"}
URL="http://localhost:8080${ENDPOINT_PATH}"
OUTPUT_FILE="benchmark_results.txt"

# Verifica se a ferramenta ab está disponível
if ! command -v ab &> /dev/null; then
    echo "Erro: Apache Benchmark (ab) não foi encontrado no sistema."
    echo "No macOS, 'ab' geralmente está instalado em /usr/sbin/ab."
    exit 1
fi

run_test() {
    local algo=$1
    echo "======================================================"
    echo " [TESTE DE CARGA] Algoritmo: $algo"
    echo " Configuração: $REQUESTS requisições | $CONCURRENCY conexões simultâneas"
    echo " URL Alvo: $URL"
    echo "======================================================"

    # Aplica o algoritmo
    ./scripts/switch-algorithm.sh "$algo" > /dev/null

    # Aguarda 1 segundo para estabilizar
    sleep 1

    local tmp_output
    tmp_output=$(mktemp)

    echo "Disparando carga com Apache Benchmark (ab)..."
    ab -n "$REQUESTS" -c "$CONCURRENCY" "$URL" > "$tmp_output" 2>&1

    # Extrai métricas principais
    local rps
    local latency
    local failed
    local length_diff
    local connect_err
    local transfer
    local non_2xx

    rps=$(grep "Requests per second:" "$tmp_output" | awk '{print $4}')
    latency=$(grep "Time per request:" "$tmp_output" | head -n1 | awk '{print $4}')
    failed=$(grep "Failed requests:" "$tmp_output" | awk '{print $3}')
    length_diff=$(grep -E "\(Connect:.*Length:" "$tmp_output" | awk -F'Length: ' '{print $2}' | awk -F',' '{print $1}' || echo "0")
    connect_err=$(grep -E "\(Connect:.*Length:" "$tmp_output" | awk -F'Connect: ' '{print $2}' | awk -F',' '{print $1}' || echo "0")
    transfer=$(grep "Transfer rate:" "$tmp_output" | awk '{print $3 " " $4}')
    non_2xx=$(grep "Non-2xx responses:" "$tmp_output" | awk '{print $3}' || echo "0")

    echo ""
    echo "--- Resultados ($algo) ---"
    echo "  Vazão (Throughput):            ${rps:-N/A} requisições/s"
    echo "  Latência média:                ${latency:-N/A} ms"
    echo "  Erros de Conexão:              ${connect_err:-0}"
    echo "  Respostas Não-2xx (HTTP Erros): ${non_2xx:-0}"
    if [[ -n "$length_diff" && "$length_diff" != "0" ]]; then
        echo "  Variação de Tamanho HTML:      ${length_diff} (esperado pelo ab ao alternar entre instâncias com IPs/IDs distintos)"
    fi
    echo "  Taxa de transferência:         ${transfer:-N/A}"
    echo "--------------------------"
    echo ""

    # Salva no arquivo de resultados
    {
        echo "======================================================"
        echo "Algoritmo: $algo"
        echo "Data/Hora: $(date)"
        echo "Parâmetros: $REQUESTS requisições, concorrência $CONCURRENCY"
        echo "URL: $URL"
        echo "Requests per second: $rps"
        echo "Time per request: $latency ms"
        echo "Connect Errors: ${connect_err:-0}"
        echo "Non-2xx Errors: ${non_2xx:-0}"
        echo "Failed requests (ab length warning): ${failed:-0}"
        echo "Transfer rate: $transfer"
        echo "------------------------------------------------------"
        cat "$tmp_output"
        echo ""
    } >> "$OUTPUT_FILE"

    rm -f "$tmp_output"
}

# Inicializa o arquivo de log
echo "=== RELATÓRIO DE BENCHMARK SHOPNOW ===" > "$OUTPUT_FILE"

if [[ "$TARGET_ALGO" == "all" ]]; then
    run_test "round-robin"
    echo "Pausa de 2 segundos antes do próximo teste..."
    sleep 2
    run_test "least-conn"
    # Restaura para round-robin como padrão
    ./scripts/switch-algorithm.sh round-robin > /dev/null
else
    run_test "$TARGET_ALGO"
fi

echo "======================================================"
echo " Teste de Benchmark concluído com sucesso!"
echo " O relatório completo foi salvo em: $OUTPUT_FILE"
echo "======================================================"
