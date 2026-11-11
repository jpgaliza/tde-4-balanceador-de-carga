#!/usr/bin/env bash

# Inicia 3 servidores locais e o balanceador em background
echo "Iniciando servidores locais PHP..."

INSTANCE_NAME=app_server1 php -S 127.0.0.1:8001 app/index.php > /dev/null 2>&1 &
PID1=$!
INSTANCE_NAME=app_server2 php -S 127.0.0.1:8002 app/index.php > /dev/null 2>&1 &
PID2=$!
INSTANCE_NAME=app_server3 php -S 127.0.0.1:8003 app/index.php > /dev/null 2>&1 &
PID3=$!

php -S 127.0.0.1:8080 load_balancer/index.php > /dev/null 2>&1 &
PID_LB=$!

echo "$PID1 $PID2 $PID3 $PID_LB" > /tmp/shopnow_pids.txt

echo " Servidores ativos:"
echo "   - app_server1: http://127.0.0.1:8001 (PID $PID1)"
echo "   - app_server2: http://127.0.0.1:8002 (PID $PID2)"
echo "   - app_server3: http://127.0.0.1:8003 (PID $PID3)"
echo "   - Balanceador: http://127.0.0.1:8080 (PID $PID_LB)"
echo ""
echo "Para testar, execute:"
echo "  curl http://127.0.0.1:8080"
