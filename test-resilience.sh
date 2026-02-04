#!/bin/bash

echo "======================================"
echo "Prueba de Resiliencia del Sistema"
echo "======================================"
echo ""

echo "1. Verificando estado actual de los Pods..."
kubectl get pods -n logistica-system

echo ""
echo "2. Verificando datos actuales en Redis..."
REDIS_POD=$(kubectl get pod -n logistica-system -l app=redis -o jsonpath='{.items[0].metadata.name}')
echo "Total de registros:"
kubectl exec -n logistica-system $REDIS_POD -- redis-cli -a SecurePassword123! LLEN sensor:data

echo ""
echo "Últimos 5 registros:"
kubectl exec -n logistica-system $REDIS_POD -- redis-cli -a SecurePassword123! LRANGE sensor:data 0 4

echo ""
echo "======================================"
echo "3. ELIMINANDO el Pod de Redis..."
echo "======================================"
kubectl delete pod -n logistica-system -l app=redis

echo ""
echo "4. Esperando a que Kubernetes recree el Pod..."
sleep 5
kubectl wait --for=condition=ready pod -l app=redis -n logistica-system --timeout=120s

echo ""
echo "======================================"
echo "5. Verificando que los datos persisten..."
echo "======================================"
REDIS_POD=$(kubectl get pod -n logistica-system -l app=redis -o jsonpath='{.items[0].metadata.name}')
echo "Total de registros después de la recreación:"
kubectl exec -n logistica-system $REDIS_POD -- redis-cli -a SecurePassword123! LLEN sensor:data

echo ""
echo "Últimos 5 registros (deben ser los mismos):"
kubectl exec -n logistica-system $REDIS_POD -- redis-cli -a SecurePassword123! LRANGE sensor:data 0 4

echo ""
echo "======================================"
echo "Prueba de Resiliencia Completada!"
echo "======================================"
echo ""
echo "✓ Si ves los mismos datos, la persistencia funciona correctamente"
echo "✓ Verifica en Redis Commander (http://localhost:30080) que el visualizador se reconectó"
