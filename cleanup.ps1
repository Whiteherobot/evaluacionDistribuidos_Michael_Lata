# Script de limpieza para PowerShell (Windows)

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Limpieza del Sistema de Monitoreo" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$confirmation = Read-Host "¿Estás seguro de eliminar todos los recursos? (s/n)"

if ($confirmation -eq 's' -or $confirmation -eq 'S') {
    Write-Host "Eliminando namespace logistica-system y todos sus recursos..." -ForegroundColor Yellow
    kubectl delete namespace logistica-system
    
    Write-Host ""
    Write-Host "✓ Limpieza completada" -ForegroundColor Green
} else {
    Write-Host "Operación cancelada" -ForegroundColor Yellow
}
