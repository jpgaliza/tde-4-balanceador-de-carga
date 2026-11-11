# Balanceador de Carga em PHP Desenvolvido do Zero (TDE 04)

Projeto minimalista de balanceador de carga em Camada 7 (HTTP) desenvolvido do zero em **PHP puro**, orquestrado via **Docker Compose**, projetado para teste e demonstração via terminal.

---

## 🏛 Arquitetura

- **`load_balancer` (Porta 8080)**: Script PHP de ~50 linhas que recebe as requisições e distribui entre os nós.
- **`app_server1`, `app_server2`, `app_server3`**: Três instâncias idênticas em PHP que respondem com seu nome e horário.

---

## ⚙ Algoritmos Implementados em Código (`load_balancer/index.php`)

1. **Round Robin (Padrão)**:
   Alterna sequencialmente entre os servidores usando um contador e operação de resto modular:
   ```php
   $selectedIndex = $counter % 3;
   ```
2. **Random (Aleatório)**:
   Sorteia um servidor aleatoriamente via:
   ```php
   $selectedIndex = array_rand($backends);
   ```

---

## 🛡 Tolerância a Falhas (Failover Automático)

No arquivo `load_balancer/index.php`, o balanceador percorre os servidores candidatos com `file_get_contents` (timeout de 1s). Se um container cair (`docker stop`), o código captura a falha e **tenta imediatamente o próximo servidor da lista**. O cliente recebe HTTP 200 com 0% de erros.

---

## 🚀 Como Executar

```bash
docker compose up -d --build
```

---

## 🧪 Comandos para Testar no Terminal

### 1. Testar o Round Robin (Distribuição Sequencial):
Execute 3 vezes seguidas:
```bash
curl http://localhost:8080/
```
> **Saída:**
> ```text
> [BALANCEADOR | Algoritmo: round_robin | Direcionado para: http://app_server1:80]
> Resposta de: app_server1 | Horario: 22:17:18
> 
> [BALANCEADOR | Algoritmo: round_robin | Direcionado para: http://app_server2:80]
> Resposta de: app_server2 | Horario: 22:17:18
> 
> [BALANCEADOR | Algoritmo: round_robin | Direcionado para: http://app_server3:80]
> Resposta de: app_server3 | Horario: 22:17:18
> ```

---

### 2. Testar o Algoritmo Random (Aleatório):
Basta passar `?algo=random` na URL:
```bash
curl "http://localhost:8080/?algo=random"
curl "http://localhost:8080/?algo=random"
```

---

### 3. Testar a Simulação de Falha (Failover ao Vivo):
```bash
# 1. Derruba o container do servidor 2
docker stop app_server2

# 2. Faz requisições (veja que continua funcionando sem nenhum erro!)
curl http://localhost:8080/
curl http://localhost:8080/

# 3. Restaura o servidor 2
docker start app_server2

# 4. Testa novamente (ele volta ao rodízio)
curl http://localhost:8080/
```

---

### 4. Teste de Carga com Apache Benchmark (`ab`):
```bash
ab -n 300 -c 15 http://localhost:8080/
```
