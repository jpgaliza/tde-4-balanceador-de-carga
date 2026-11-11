<?php
$instance = getenv('INSTANCE_NAME') ?: 'app_server1';
header('Content-Type: text/plain');
echo "Resposta de: $instance | Horario: " . date('H:i:s') . "\n";
