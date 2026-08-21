#!/bin/bash

API_URL="https://vw0cw6rvr8.execute-api.us-east-1.amazonaws.com/prod/"

echo "=========================================="
echo "1. Teste de Requisição Legítima"
echo "=========================================="
curl -i -X GET "$API_URL"

echo -e "\n\n=========================================="
echo "2. Teste de Bloqueio WAF (SQL Injection)"
echo "=========================================="
curl -i -X GET "${API_URL}?username=admin'%20OR%20'1'='1"

echo -e "\n\n=========================================="
echo "3. Teste de Rate Limiting (Disparando 150 requisições)"
echo "=========================================="
for i in {1..150}; do
  curl -s -o /dev/null "$API_URL"
done

echo "Aguardando 30 segundos para a métrica do WAF atualizar..."
sleep 30

echo "Tentando requisição após o estouro do limite:"
curl -i -X GET "$API_URL"