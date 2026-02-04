#!/bin/bash

echo "======================================"
echo "Sistema de Monitoreo - Despliegue"
echo "======================================"
echo ""

# Aplicar archivos en orden
echo "1. Creando namespace..."
kubectl apply -f 00-namespace.yaml

echo ""
echo "2. Creando secrets..."
kubectl apply -f 01-redis-secret.yaml

echo ""
echo "3. Desplegando Redis con persistencia..."
kubectl apply -f 02-redis-deployment.yaml

echo ""
echo "Esperando a que Redis esté listo..."
kubectl wait --for=condition=ready pod -l app=redis -n logistica-system --timeout=120s

echo ""
echo "4. Desplegando Productor (Sensor)..."
kubectl apply -f 03-productor-deployment.yaml

echo ""
echo "5. Desplegando Cliente (Visualizador)..."
kubectl apply -f 04-cliente-deployment.yaml

echo ""
echo "======================================"
echo "Verificando estado de los Pods..."
echo "======================================"
kubectl get pods -n logistica-system

echo ""
echo "======================================"
echo "Verificando servicios..."
echo "======================================"
kubectl get services -n logistica-system

echo ""
echo "======================================"
echo "Despliegue completado!"
echo "======================================"
echo ""
echo "Acceder a Redis Commander en: http://localhost:30080"
echo ""
echo "Para ver los logs del productor:"
echo "  kubectl logs -n logistica-system deployment/productor -f"
echo ""
echo "Para verificar datos en Redis:"
echo "  kubectl exec -it -n logistica-system deployment/redis -- redis-cli -a SecurePassword123! LRANGE sensor:data 0 -1"
