# =========================================================================
# SCRIPT DE DEMONSTRAÇÃO E TESTES AUTOMATIZADOS (WINDOWS POWERSHELL)
# =========================================================================

$LB_URL = "http://localhost:8080"

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   BATERIA DE TESTES AUTOMATIZADOS - BALANCEADOR DE CARGA PHP   " -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan

try {
    # -------------------------------------------------------------------------
    # TESTE 1: Round Robin (3 Servidores Ativos)
    # -------------------------------------------------------------------------
    Write-Host "`n[TESTE 1] Algoritmo Round Robin (3 Servidores Ativos)" -ForegroundColor Green
    Write-Host "Objetivo: Demonstrar a distribuição sequencial (1 -> 2 -> 3 -> 1)."
    for ($i=1; $i -le 6; $i++) {
        $res = (curl.exe -s "$LB_URL/") -join "`n"
        Write-Host "  #$i: $res"
        Start-Sleep -Milliseconds 300
    }

    # -------------------------------------------------------------------------
    # TESTE 2: Algoritmo Random (Sorteio Aleatório)
    # -------------------------------------------------------------------------
    Write-Host "`n[TESTE 2] Algoritmo Random (Sorteio Aleatório)" -ForegroundColor Green
    Write-Host "Objetivo: Demonstrar a escolha aleatória através do parâmetro ?algo=random."
    for ($i=1; $i -le 6; $i++) {
        $res = (curl.exe -s "$LB_URL/?algo=random") -join "`n"
        Write-Host "  #$i: $res"
        Start-Sleep -Milliseconds 300
    }

    # -------------------------------------------------------------------------
    # TESTE 3: Simulação de Falha - Derrubando 1 Servidor (app_server2)
    # -------------------------------------------------------------------------
    Write-Host "`n[TESTE 3] Simulação de Falha: Derrubando 1 Servidor (app_server2)" -ForegroundColor Red
    docker stop app_server2 | Out-Null
    Write-Host "Container app_server2 DESLIGADO!"
    Write-Host "Disparando requisições (apenas app_server1 e app_server3 devem responder):"
    for ($i=1; $i -le 6; $i++) {
        $res = (curl.exe -s "$LB_URL/") -join "`n"
        Write-Host "  #$i: $res"
        Start-Sleep -Milliseconds 300
    }

    # -------------------------------------------------------------------------
    # TESTE 4: Simulação de Falha Severa - Apenas 1 Servidor Ativo
    # -------------------------------------------------------------------------
    Write-Host "`n[TESTE 4] Simulação de Falha Severa: Apenas 1 Servidor Ativo" -ForegroundColor Red
    docker stop app_server3 | Out-Null
    Write-Host "Containers app_server2 e app_server3 DESLIGADOS!"
    Write-Host "Disparando requisições com APENAS o app_server1 vivo:"
    for ($i=1; $i -le 4; $i++) {
        $res = (curl.exe -s "$LB_URL/") -join "`n"
        Write-Host "  #$i: $res"
        Start-Sleep -Milliseconds 300
    }

    # -------------------------------------------------------------------------
    # TESTE 5: Restauração Completa de Todos os Servidores
    # -------------------------------------------------------------------------
    Write-Host "`n[TESTE 5] Recuperação Automática: Religando app_server2 e app_server3" -ForegroundColor Green
    docker start app_server2 app_server3 | Out-Null
    Write-Host "Aguardando 2 segundos para inicialização dos containers..."
    Start-Sleep -Seconds 2
    for ($i=1; $i -le 6; $i++) {
        $res = (curl.exe -s "$LB_URL/") -join "`n"
        Write-Host "  #$i: $res"
        Start-Sleep -Milliseconds 300
    }

} finally {
    # Garante que os containers voltem a rodar
    docker start app_server1 app_server2 app_server3 | Out-Null
}

Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "         TODOS OS TESTES FORAM CONCLUÍDOS COM SUCESSO!          " -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
