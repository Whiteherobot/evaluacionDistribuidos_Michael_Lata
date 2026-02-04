# Sistema de Monitoreo en Tiempo Real - Almacenes Automatizados

## Justificación Técnica de la Arquitectura

### Base de Datos Seleccionada: Redis

**Imagen elegida:** `redis:7-alpine`

**Justificación técnica:**

1. **Alta velocidad:** Redis es una base de datos en memoria que ofrece operaciones de lectura/escritura extremadamente rápidas (sub-milisegundo), ideal para datos volátiles de alta velocidad en sensores IoT.

2. **Estructura de datos flexible:** Soporta múltiples estructuras (strings, lists, hashes, sets) lo que permite almacenar los datos JSON de sensores de manera eficiente.

3. **Persistencia configurable:** Ofrece RDB (snapshots) y AOF (append-only file) para garantizar durabilidad de datos.

4. **Ligereza:** La imagen Alpine reduce el tamaño del contenedor manteniendo funcionalidad completa.

5. **Autenticación integrada:** Soporta autenticación mediante contraseña (requirepass) de forma nativa.

6. **Ecosistema maduro:** Excelente soporte de clientes en múltiples lenguajes y herramientas de administración web probadas.

### Componentes del Sistema

#### 1. Capa de Persistencia (Redis)
- Deployment con 1 réplica
- PersistentVolumeClaim de 1Gi para datos persistentes
- Autenticación obligatoria mediante Secret
- Persistencia AOF activada para máxima durabilidad

#### 2. Microservicio Productor (Sensor IoT)
- Imagen base: `python:3.11-alpine` (ligera y con soporte para redis-py)
- Script Python inyectado vía ConfigMap
- Genera datos aleatorios cada 3 segundos
- Autenticación automática con Redis

#### 3. Microservicio Cliente (Redis Commander)
- Imagen: `rediscommander/redis-commander:latest`
- Interfaz web para visualizar datos en tiempo real
- Expuesto via NodePort (puerto 30080)

## Instrucciones de Despliegue

### 1. Crear el namespace
```bash
kubectl apply -f 00-namespace.yaml
```

### 2. Desplegar el Secret con las credenciales
```bash
kubectl apply -f 01-redis-secret.yaml
```

### 3. Desplegar Redis con persistencia
```bash
kubectl apply -f 02-redis-deployment.yaml
```

### 4. Desplegar el Productor (Sensor)
```bash
kubectl apply -f 03-productor-deployment.yaml
```

### 5. Desplegar el Cliente (Visualizador)
```bash
kubectl apply -f 04-cliente-deployment.yaml
```

### 6. Desplegar todo de una vez (alternativa)
```bash
kubectl apply -f .
```

## Verificación del Sistema

### Verificar que todos los Pods estén corriendo
```bash
kubectl get pods -n logistica-system
```

### Ver los logs del productor
```bash
kubectl logs -n logistica-system deployment/productor -f
```

### Acceder a la interfaz web
Abrir en el navegador: `http://localhost:30080`

**Credenciales:**
- No requiere login en Redis Commander (auto-configurado)

### Verificar datos en Redis
```bash
kubectl exec -it -n logistica-system deployment/redis -- redis-cli -a SecurePassword123! KEYS "*"
kubectl exec -it -n logistica-system deployment/redis -- redis-cli -a SecurePassword123! LRANGE sensor:data 0 -1
```

## Prueba de Resiliencia

### 1. Verificar datos existentes
Abrir Redis Commander y verificar que hay datos de sensores.

### 2. Eliminar el Pod de Redis
```bash
kubectl delete pod -n logistica-system -l app=redis
```

### 3. Verificar recreación automática
```bash
kubectl get pods -n logistica-system -w
```

### 4. Verificar persistencia de datos
Una vez que el nuevo Pod esté en estado Running, acceder nuevamente a Redis Commander y verificar que los datos anteriores siguen disponibles.

### 5. Verificar reconexión del visualizador
El cliente Redis Commander debe reconectarse automáticamente y mostrar todos los datos históricos.

## Limpieza

Para eliminar todos los recursos:
```bash
kubectl delete namespace logistica-system
```

## Estructura de Datos

Cada registro de sensor se almacena en Redis con el siguiente formato JSON:
```json
{
  "sensor_id": "rbt-01",
  "valor": 42.7,
  "timestamp": "2026-02-04 15:30:45"
}
```

Los datos se almacenan en una lista de Redis con la clave `sensor:data`.

## Arquitectura - Tabla de Tecnologías Seleccionadas

| Componente | Tecnología | Imagen | Justificación |
|------------|-----------|--------|--------------|
| Base de Datos | Redis | redis:7-alpine | BD NoSQL en memoria con persistencia AOF y autenticación nativa. Ideal para datos volátiles de alta velocidad con latencia sub-milisegundo. |
| Productor | Python + Redis Client | python:3.11-alpine | Imagen ligera que genera datos de sensores cada 3 segundos con autenticación automática inyectada vía Secret. |
| Cliente Web | Flask | python:3.11-alpine | Interfaz web simple para visualizar datos en tabla HTML con auto-actualización cada 3 segundos. |
| Orquestación | Kubernetes | Minikube | Gestión de contenedores con auto-recuperación de fallos, PersistentVolumeClaim para durabilidad y Secrets para credenciales. |
| Almacenamiento | PersistentVolume | Local | Volumen de 1Gi que garantiza persistencia de datos incluso tras eliminación del pod Redis. |
| Networking | Services | ClusterIP + NodePort | Conectividad interna entre componentes y exposición externa en puerto 30081. |

Resultado de Prueba de Resiliencia: Luego de eliminar manualmente el Pod de Redis, Kubernetes lo reconstruyó automáticamente y los 798 registros almacenados persistieron correctamente en el volumen, demostrando la robustez del sistema.
