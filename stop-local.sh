#!/usr/bin/env bash

if [ -f /tmp/shopnow_pids.txt ]; then
    kill $(cat /tmp/shopnow_pids.txt) 2>/dev/null || true
    rm -f /tmp/shopnow_pids.txt
    echo "Servidores locais encerrados com sucesso."
else
    # Mata qualquer processo php nessas portas se houver
    kill $(lsof -t -i :8080 -i :8001 -i :8002 -i :8003) 2>/dev/null || true
    echo "Processos encerrados."
fi
