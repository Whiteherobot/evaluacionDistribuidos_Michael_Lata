# Sistema de Monitoreo en Tiempo Real - Almacenes Automatizados

##  Arquitectura

### Base de Datos Seleccionada: Redis

**Imagen elegida:** `redis:7-alpine`


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
