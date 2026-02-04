# Script de prueba de resiliencia para PowerShell (Windows)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Prueba de Resiliencia del Sistema" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Verificando estado actual de los Pods..." -ForegroundColor Yellow
kubectl get pods -n logistica-system

Write-Host ""
Write-Host "2. Verificando datos actuales en Redis..." -ForegroundColor Yellow
$REDIS_POD = kubectl get pod -n logistica-system -l app=redis -o jsonpath='{.items[0].metadata.name}'
Write-Host "Total de registros:" -ForegroundColor White
kubectl exec -n logistica-system $REDIS_POD -- redis-cli -a SecurePassword123! LLEN sensor:data

Write-Host ""
Write-Host "Últimos 5 registros:" -ForegroundColor White
kubectl exec -n logistica-system $REDIS_POD -- redis-cli -a SecurePassword123! LRANGE sensor:data 0 4

Write-Host ""
Write-Host "======================================" -ForegroundColor Red
Write-Host "3. ELIMINANDO el Pod de Redis..." -ForegroundColor Red
Write-Host "======================================" -ForegroundColor Red
kubectl delete pod -n logistica-system -l app=redis

Write-Host ""
Write-Host "4. Esperando a que Kubernetes recree el Pod..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
kubectl wait --for=condition=ready pod -l app=redis -n logistica-system --timeout=120s

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "5. Verificando que los datos persisten..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
$REDIS_POD = kubectl get pod -n logistica-system -l app=redis -o jsonpath='{.items[0].metadata.name}'
Write-Host "Total de registros después de la recreación:" -ForegroundColor White
kubectl exec -n logistica-system $REDIS_POD -- redis-cli -a SecurePassword123! LLEN sensor:data

Write-Host ""
Write-Host "Últimos 5 registros (deben ser los mismos):" -ForegroundColor White
kubectl exec -n logistica-system $REDIS_POD -- redis-cli -a SecurePassword123! LRANGE sensor:data 0 4

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Prueba de Resiliencia Completada!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "✓ Si ves los mismos datos, la persistencia funciona correctamente" -ForegroundColor Green
Write-Host "✓ Verifica en Redis Commander (http://localhost:30080) que el visualizador se reconectó" -ForegroundColor Green
