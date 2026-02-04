#!/bin/bash

echo "======================================"
echo "Limpieza del Sistema de Monitoreo"
echo "======================================"
echo ""

read -p "¿Estás seguro de eliminar todos los recursos? (s/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Ss]$ ]]
then
    echo "Eliminando namespace logistica-system y todos sus recursos..."
    kubectl delete namespace logistica-system
    
    echo ""
    echo "✓ Limpieza completada"
else
    echo "Operación cancelada"
fi
