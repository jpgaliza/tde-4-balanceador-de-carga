<?php
header('Content-Type: application/json');

$instanceName = getenv('INSTANCE_NAME') ?: gethostname();

http_response_code(200);
echo json_encode([
    'status' => 'UP',
    'instance' => $instanceName,
    'hostname' => gethostname(),
    'timestamp' => date('Y-m-d H:i:s'),
    'uptime' => sys_getloadavg()
]);
