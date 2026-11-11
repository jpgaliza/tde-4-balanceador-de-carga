<?php
// =========================================================================
// BALANCEADOR DE CARGA EM PHP (DO ZERO)
// =========================================================================

// 1. Lista de servidores (configurável por ambiente ou padrão local)
$defaultBackends = 'http://127.0.0.1:8001,http://127.0.0.1:8002,http://127.0.0.1:8003';
$backends = explode(',', getenv('BACKENDS') ?: $defaultBackends);
$total = count($backends);

// 2. Escolha do algoritmo: 'round_robin' ou 'random'
$algoFile = sys_get_temp_dir() . '/lb_algo.txt';
$algo = $_GET['algo'] ?? (file_exists($algoFile) ? trim(file_get_contents($algoFile)) : 'round_robin');

// 3. Ordem de tentativa dos servidores
$order = [];
if ($algo === 'random') {
    // Algoritmo: Random (Aleatório)
    $first = array_rand($backends);
    $order[] = $first;
    for ($i = 0; $i < $total; $i++) {
        if ($i !== $first) $order[] = $i;
    }
} else {
    // Algoritmo: Round Robin (Sequencial cíclico)
    $counterFile = sys_get_temp_dir() . '/lb_counter.txt';
    $counter = file_exists($counterFile) ? (int)file_get_contents($counterFile) : 0;
    file_put_contents($counterFile, $counter + 1);

    for ($i = 0; $i < $total; $i++) {
        $order[] = ($counter + $i) % $total;
    }
}

// 4. Encaminhamento com Failover automático
header('Content-Type: text/plain');

foreach ($order as $idx) {
    $target = $backends[$idx];
    
    // Tenta conectar no servidor com timeout de 1 segundo
    $ctx = stream_context_create(['http' => ['timeout' => 1]]);
    $response = @file_get_contents($target, false, $ctx);

    if ($response !== false) {
        header("X-Backend-Used: $target");
        header("X-Algorithm-Used: $algo");
        echo "[BALANCEADOR | Algoritmo: $algo | Direcionado para: $target]\n";
        echo $response;
        exit;
    }
    // Se falhar (servidor caído), o loop tenta o próximo da lista!
}

// 5. Se todos os servidores falharem
http_response_code(503);
echo "Erro 503: Todos os servidores backend estao fora do ar!\n";
