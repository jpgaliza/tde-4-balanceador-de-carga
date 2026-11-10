<?php
$instanceName = getenv('INSTANCE_NAME') ?: gethostname();
$serverHost = gethostname();
$serverIp = gethostbyname($serverHost);
$clientIp = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'];
$requestTime = date('d/m/Y H:i:s');

// Configuração visual por instância para facilitar a identificação
$instanceColors = [
    'app_server1' => ['bg' => 'bg-emerald-600', 'border' => 'border-emerald-500', 'badge' => 'bg-emerald-100 text-emerald-800'],
    'app_server2' => ['bg' => 'bg-blue-600', 'border' => 'border-blue-500', 'badge' => 'bg-blue-100 text-blue-800'],
    'app_server3' => ['bg' => 'bg-purple-600', 'border' => 'border-purple-500', 'badge' => 'bg-purple-100 text-purple-800']
];

$theme = $instanceColors[$instanceName] ?? ['bg' => 'bg-slate-700', 'border' => 'border-slate-500', 'badge' => 'bg-slate-100 text-slate-800'];

$products = [
    ['name' => 'Smartphone Galaxy Ultra', 'price' => 'R$ 4.899,00', 'old_price' => 'R$ 6.299,00', 'category' => 'Smartphones', 'badge' => 'Black Friday -22%'],
    ['name' => 'Notebook Pro 16" M3', 'price' => 'R$ 11.499,00', 'old_price' => 'R$ 13.999,00', 'category' => 'Informática', 'badge' => 'Oferta Relâmpago'],
    ['name' => 'Headphone Noise Cancelling', 'price' => 'R$ 899,00', 'old_price' => 'R$ 1.299,00', 'category' => 'Áudio', 'badge' => 'Mais Vendido'],
    ['name' => 'Smartwatch Sport Fit', 'price' => 'R$ 649,00', 'old_price' => 'R$ 950,00', 'category' => 'Wearables', 'badge' => 'Destaque']
];
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ShopNow - E-commerce em Alta Disponibilidade</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @keyframes pulse-subtle {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.85; }
        }
        .animate-subtle {
            animation: pulse-subtle 2s infinite ease-in-out;
        }
    </style>
</head>
<body class="bg-gray-50 text-gray-800 flex flex-col min-h-screen">

    <!-- Top Diagnostic Banner (Load Balancer Info) -->
    <header class="<?= $theme['bg'] ?> text-white shadow-lg sticky top-0 z-50 transition-colors duration-300">
        <div class="max-w-7xl mx-auto px-4 py-3 sm:px-6 lg:px-8">
            <div class="flex flex-wrap items-center justify-between gap-4">
                <div class="flex items-center space-x-3">
                    <span class="flex h-3 w-3 relative">
                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-white opacity-75"></span>
                        <span class="relative inline-flex rounded-full h-3 w-3 bg-white"></span>
                    </span>
                    <div>
                        <p class="text-xs uppercase tracking-wider text-white/80 font-semibold">Instância Ativa (Load Balancer Target)</p>
                        <h1 class="text-xl sm:text-2xl font-black tracking-tight flex items-center gap-2">
                            <?= htmlspecialchars($instanceName) ?>
                            <span class="text-xs px-2 py-0.5 rounded-full bg-white/20 font-mono font-medium">PHP 8.2</span>
                        </h1>
                    </div>
                </div>

                <div class="flex flex-wrap items-center gap-2 sm:gap-4 text-xs font-mono bg-black/20 px-3 py-2 rounded-lg">
                    <div>
                        <span class="text-white/60">Host:</span>
                        <span class="font-bold text-white"><?= htmlspecialchars($serverHost) ?></span>
                    </div>
                    <span class="text-white/30 hidden sm:inline">|</span>
                    <div>
                        <span class="text-white/60">IP Container:</span>
                        <span class="font-bold text-white"><?= htmlspecialchars($serverIp) ?></span>
                    </div>
                    <span class="text-white/30 hidden sm:inline">|</span>
                    <div>
                        <span class="text-white/60">Horário:</span>
                        <span class="font-bold text-white"><?= $requestTime ?></span>
                    </div>
                </div>

                <div class="flex items-center gap-2">
                    <button onclick="window.location.reload();" class="bg-white text-gray-900 hover:bg-gray-100 px-3 py-1.5 rounded-md text-xs font-bold shadow transition flex items-center gap-1.5 cursor-pointer">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path></svg>
                        Recarregar (F5)
                    </button>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
        <!-- Banner Black Friday -->
        <div class="bg-gradient-to-r from-gray-900 via-gray-800 to-black rounded-2xl p-6 sm:p-8 text-white shadow-xl mb-8 relative overflow-hidden">
            <div class="relative z-10 max-w-2xl">
                <span class="bg-red-600 text-white text-xs font-bold px-2.5 py-1 rounded-md uppercase tracking-wider">Black Friday ShopNow</span>
                <h2 class="text-3xl sm:text-4xl font-extrabold mt-3 mb-2">Grandes Ofertas, Alta Disponibilidade</h2>
                <p class="text-gray-300 text-sm sm:text-base mb-6">
                    Arquitetura resiliente escalada para milhares de acessos simultâneos sem lentidão ou quedas.
                </p>
                <div class="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm px-3 py-1.5 rounded-lg text-xs font-mono text-gray-200">
                    <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
                    <span>Requisição roteada com sucesso via Proxy Balanceador</span>
                </div>
            </div>
            <div class="absolute right-0 bottom-0 opacity-10 translate-x-10 translate-y-10 pointer-events-none">
                <svg class="w-96 h-96" fill="currentColor" viewBox="0 0 24 24"><path d="M7 18c-1.1 0-1.99.9-1.99 2S5.9 22 7 22s2-.9 2-2-.9-2-2-2zM1 2v2h2l3.6 7.59-1.35 2.45c-.16.28-.25.61-.25.96 0 1.1.9 2 2 2h12v-2H7.42c-.14 0-.25-.11-.25-.25l.03-.12.9-1.63h7.45c.75 0 1.41-.41 1.75-1.03l3.58-6.49c.08-.14.12-.31.12-.48 0-.55-.45-1-1-1H5.21l-.94-2H1zm16 16c-1.1 0-1.99.9-1.99 2s.89 2 1.99 2 2-.9 2-2-.9-2-2-2z"/></svg>
            </div>
        </div>

        <!-- Products Grid -->
        <div class="mb-8">
            <div class="flex items-center justify-between mb-6">
                <div>
                    <h3 class="text-xl font-bold text-gray-900">Produtos em Destaque</h3>
                    <p class="text-xs text-gray-500">Simulação de catálogo de alto tráfego</p>
                </div>
                <span class="text-xs font-medium text-gray-500">Status do Cluster: <strong class="text-emerald-600">Online</strong></span>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                <?php foreach ($products as $product): ?>
                <div class="bg-white rounded-xl border border-gray-200 shadow-sm hover:shadow-md transition duration-200 overflow-hidden flex flex-col">
                    <div class="bg-gray-100 h-40 flex items-center justify-center p-4 relative">
                        <span class="absolute top-2 left-2 bg-red-500 text-white text-[10px] font-bold px-2 py-0.5 rounded">
                            <?= $product['badge'] ?>
                        </span>
                        <svg class="w-16 h-16 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path></svg>
                    </div>
                    <div class="p-4 flex-grow flex flex-col justify-between">
                        <div>
                            <span class="text-[11px] font-semibold text-gray-400 uppercase tracking-wide"><?= $product['category'] ?></span>
                            <h4 class="font-bold text-gray-900 text-sm mt-1"><?= $product['name'] ?></h4>
                            <div class="mt-2">
                                <span class="text-xs text-gray-400 line-through"><?= $product['old_price'] ?></span>
                                <p class="text-base font-extrabold text-emerald-600"><?= $product['price'] ?></p>
                            </div>
                        </div>
                        <button class="mt-4 w-full bg-gray-900 hover:bg-black text-white text-xs font-semibold py-2 px-3 rounded-lg transition">
                            Adicionar ao Carrinho
                        </button>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>
        </div>

        <!-- Architecture Technical Details Box -->
        <div class="bg-white rounded-xl border border-gray-200 p-6 shadow-sm">
            <h4 class="text-sm font-bold text-gray-900 mb-3 flex items-center gap-2">
                <svg class="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
                Detalhes Técnicos do Balanceamento
            </h4>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs text-gray-600">
                <div class="p-3 bg-gray-50 rounded-lg border border-gray-100">
                    <span class="font-semibold block text-gray-700">Cluster:</span>
                    <span>3 instâncias PHP (app_server1, app_server2, app_server3)</span>
                </div>
                <div class="p-3 bg-gray-50 rounded-lg border border-gray-100">
                    <span class="font-semibold block text-gray-700">Balanceador:</span>
                    <span>Nginx Reverse Proxy & Load Balancer</span>
                </div>
                <div class="p-3 bg-gray-50 rounded-lg border border-gray-100">
                    <span class="font-semibold block text-gray-700">Tolerância a Falhas:</span>
                    <span>Failover automático com detecção via upstream status</span>
                </div>
            </div>
        </div>
    </main>

    <footer class="bg-white border-t border-gray-200 py-4 text-center text-xs text-gray-500">
        ShopNow E-Commerce &copy; <?= date('Y') ?> - Trabalho de Balanceamento de Carga (TDE 04)
    </footer>

</body>
</html>
