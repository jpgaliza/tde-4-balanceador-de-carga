<?php
/**
 * =========================================================================
 * BALANCEADOR DE CARGA EM PHP (DESENVOLVIDO DO ZERO) - SHOPNOW (TDE 04)
 * =========================================================================
 * Escuta na porta 8080 e distribui as requisições entre 3 instâncias de backend.
 */

// 1. LISTA DOS SERVIDORES BACKEND (Instâncias da ShopNow)
$backends = [
    'http://app_server1:80',
    'http://app_server2:80',
    'http://app_server3:80'
];

$counterFile = '/tmp/lb_counter.txt';
$algoFile    = '/tmp/lb_algorithm.txt';

// 2. DEFINIÇÃO DO ALGORITMO (Via URL ?algo= ou arquivo de configuração)
$algorithm = $_GET['algo'] ?? (file_exists($algoFile) ? trim(file_get_contents($algoFile)) : 'round_robin');
if (!in_array($algorithm, ['round_robin', 'random'])) {
    $algorithm = 'round_robin';
}

// 3. SELEÇÃO DO SERVIDOR INICIAL BASEADA NO ALGORITMO ESCOLHIDO
$totalBackends = count($backends);
$candidates = [];

if ($algorithm === 'random') {
    // ALGORITMO 1: RANDOM (Sorteio aleatório)
    $randomIndex = array_rand($backends);
    $candidates[] = $backends[$randomIndex];
    // Adiciona os demais como fallback para failover
    foreach ($backends as $idx => $b) {
        if ($idx !== $randomIndex) $candidates[] = $b;
    }
} else {
    // ALGORITMO 2: ROUND ROBIN (Distribuição sequencial cíclica)
    $counter = file_exists($counterFile) ? (int)file_get_contents($counterFile) : 0;
    $selectedIndex = $counter % $totalBackends;
    file_put_contents($counterFile, ($counter + 1) % 1000000);

    // Ordem de tentativa começando pelo selecionado
    for ($i = 0; $i < $totalBackends; $i++) {
        $candidates[] = $backends[($selectedIndex + $i) % $totalBackends];
    }
}

// 4. MECANISMO DE ENCAMINHAMENTO COM FAILOVER AUTOMÁTICO
// Monta o caminho solicitado pelo cliente (ex: / ou /health.php)
$requestUri = $_SERVER['REQUEST_URI'] ?? '/';
// Remove o parâmetro ?algo= para repassar a URL limpa ao backend
$cleanUri = preg_replace('/(\?|&)algo=[^&]*/', '', $requestUri);
if ($cleanUri === '' || $cleanUri === '?') $cleanUri = '/';

$responseBody = false;
$httpCode = 503;
$chosenBackend = null;

// Tenta os servidores em ordem. Se um estiver fora do ar, tenta o próximo!
foreach ($candidates as $backend) {
    $targetUrl = rtrim($backend, '/') . $cleanUri;

    $ch = curl_init($targetUrl);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 1); // Timeout de conexão rápido (1s)
    curl_setopt($ch, CURLOPT_TIMEOUT, 3);        // Timeout total rápido (3s)
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);

    $result = curl_exec($ch);
    $code   = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error  = curl_errno($ch);
    curl_close($ch);

    // Se respondeu com sucesso (código 200..399 e sem erro de conexão), concluímos!
    if (!$error && $code >= 200 && $code < 500) {
        $responseBody = $result;
        $httpCode = $code;
        $chosenBackend = $backend;
        break;
    }
    // Caso falhe (servidor caiu), o loop automaticamente tenta o próximo candidato!
}

// 5. RESPOSTA AO CLIENTE
http_response_code($httpCode);
header('X-Load-Balancer: Custom-PHP-Load-Balancer');
header('X-Algorithm-Used: ' . $algorithm);
if ($chosenBackend) {
    header('X-Backend-Server: ' . $chosenBackend);
}

if ($responseBody !== false) {
    echo $responseBody;
} else {
    echo "<h1>Erro 503 - Todos os servidores de backend estão indisponíveis</h1>";
}
