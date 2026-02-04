# Script de despliegue para PowerShell (Windows)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Sistema de Monitoreo - Despliegue" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Aplicar archivos en orden
Write-Host "1. Creando namespace..." -ForegroundColor Yellow
kubectl apply -f 00-namespace.yaml

Write-Host ""
Write-Host "2. Creando secrets..." -ForegroundColor Yellow
kubectl apply -f 01-redis-secret.yaml

Write-Host ""
Write-Host "3. Desplegando Redis con persistencia..." -ForegroundColor Yellow
kubectl apply -f 02-redis-deployment.yaml

Write-Host ""
Write-Host "Esperando a que Redis esté listo..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=redis -n logistica-system --timeout=120s

Write-Host ""
Write-Host "4. Desplegando Productor (Sensor)..." -ForegroundColor Yellow
kubectl apply -f 03-productor-deployment.yaml

Write-Host ""
Write-Host "5. Desplegando Cliente (Visualizador)..." -ForegroundColor Yellow
kubectl apply -f 04-cliente-deployment.yaml

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Verificando estado de los Pods..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
kubectl get pods -n logistica-system

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Verificando servicios..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
kubectl get services -n logistica-system

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Despliegue completado!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Acceder a Redis Commander en: http://localhost:30080" -ForegroundColor White
Write-Host ""
Write-Host "Para ver los logs del productor:" -ForegroundColor White
Write-Host "  kubectl logs -n logistica-system deployment/productor -f" -ForegroundColor Gray
Write-Host ""
Write-Host "Para verificar datos en Redis:" -ForegroundColor White
Write-Host "  kubectl exec -it -n logistica-system deployment/redis -- redis-cli -a SecurePassword123! LRANGE sensor:data 0 -1" -ForegroundColor Gray
