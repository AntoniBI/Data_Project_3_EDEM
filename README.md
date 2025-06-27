# Data Project 3 - E-commerce con Replicación de Datos

Este proyecto implementa una solución completa de e-commerce con arquitectura cloud híbrida (AWS + GCP) y replicación de datos en tiempo real usando Google Cloud DataStream.

## Arquitectura del Sistema

### Componentes Principales

#### 1. **Backend en AWS Lambda**
- **Funciones Lambda**:
  - `getProducts`: Obtiene todos los productos de la base de datos
  - `add`: Añade nuevos productos con validación
  - `buy`: Procesa compras y actualiza el stock
- **Base de Datos**: PostgreSQL en AWS RDS
- **Red**: VPC con subredes privadas y públicas

#### 2. **Frontend Web en Google Cloud Run**
- **Aplicación Flask** containerizada
- Interfaz web para gestión de productos y compras
- Integración con las funciones Lambda de AWS

#### 3. **Replicación de Datos con DataStream**
- **Google Cloud DataStream** para replicación en tiempo real
- Replica datos desde PostgreSQL (AWS RDS) hacia BigQuery (GCP)
- Configuración de tablas: `productos` y `test_datastream`

#### 4. **Almacén de Datos en BigQuery**
- Dataset `productos_tienda` para análisis
- Esquema definido para productos con campos: id, name, category, price, stock

## Tecnologías Utilizadas

### Cloud Providers
- **AWS**: Lambda, RDS (PostgreSQL), VPC
- **Google Cloud**: Cloud Run, DataStream, BigQuery, Artifact Registry

### Lenguajes y Frameworks
- **Python**: Flask para la aplicación web
- **Lambda Runtime**: Python 3.x
- **Terraform**: Infraestructura como código

### Librerías Principales
- `Flask`: Framework web
- `boto3`: SDK de AWS para Python
- `pg8000`: Driver PostgreSQL para Python
- `google-cloud-*`: SDKs de Google Cloud

## Estructura del Proyecto

```
Data_Project_3/
├── Terraform/
│   ├── main.tf                    # Configuración principal
│   ├── variables.tf               # Variables globales
│   └── Modulos/
│       ├── ArtifactRegistry/      # Registro de contenedores
│       ├── Bigquery/              # Dataset y tablas
│       ├── CloudRun/              # Servicio web
│       ├── DataStream/            # Replicación de datos
│       └── VPC-LAMBDA-RDS/        # Infraestructura AWS
│           ├── Lambdas/
│           │   ├── getProducts.py
│           │   ├── add.py
│           │   ├── buy.py
│           │   └── requirements.txt
│           ├── app.py             # Aplicación Flask
│           ├── dockerfile         # Imagen Docker
│           └── templates/
│               └── index.html     # Interfaz web
```

## Funcionalidades

### E-commerce
- **Catálogo de productos**: Visualización en tabla responsive
- **Añadir productos**: Formulario con validación
- **Compras**: Sistema de carrito con actualización de stock
- **Gestión de inventario**: Control automático de stock

### Replicación de Datos
- **Tiempo real**: Los cambios en PostgreSQL se replican automáticamente a BigQuery
- **Análisis**: Datos disponibles para análisis y reportes en BigQuery
- **Monitoreo**: DataStream proporciona métricas de replicación

## Despliegue

### Prerrequisitos
- Terraform instalado
- Credenciales configuradas para AWS y GCP
- Docker para construir imágenes

### Pasos de Despliegue

1. **Configurar variables**:
   ```bash
   # Actualizar variables en Terraform/variables.tf
   ```

2. **Desplegar infraestructura**:
   ```bash
   cd Terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. **Configurar DataStream**:
   - El stream se configura automáticamente para replicar las tablas especificadas
   - Estado deseado: `RUNNING`

## Configuración de Red

### AWS VPC
- Subredes públicas y privadas
- Internet Gateway y NAT Gateway
- Security Groups para Lambda y RDS

### Conectividad Híbrida
- Cloud Run se conecta a Lambda via API REST
- DataStream accede a RDS a través de conexión privada

## Variables de Entorno

### Cloud Run (GCP)
- `AWS_ACCESS_KEY_ID`: Credenciales AWS
- `AWS_SECRET_ACCESS_KEY`: Credenciales AWS
- `PORT`: Puerto de la aplicación (8080)

### Lambda (AWS)
- `DB_HOST`: Host de la base de datos PostgreSQL
- `DB_USER`: Usuario de la base de datos
- `DB_PASSWORD`: Contraseña de la base de datos
- `DB_NAME`: Nombre de la base de datos

## Monitoreo y Logs

- **Cloud Run**: Logs en Google Cloud Logging
- **Lambda**: CloudWatch Logs
- **DataStream**: Métricas de replicación en Google Cloud Monitoring

## Seguridad

- **IAM**: Roles y permisos mínimos necesarios
- **VPC**: Subredes privadas para bases de datos
- **Secrets**: Variables de entorno para credenciales
- **CORS**: Configuración para acceso web

## Costos Estimados

- **AWS Lambda**: Pay-per-execution
- **AWS RDS**: Instancia PostgreSQL
- **Google Cloud Run**: Pay-per-request
- **DataStream**: Basado en volumen de datos replicados
- **BigQuery**: Storage + queries

## Autor

Proyecto desarrollado para EDEM - Data Project 3

---

**Nota**: Este proyecto demuestra una arquitectura moderna de datos con replicación en tiempo real entre diferentes proveedores cloud, ideal para casos de uso de e-commerce con necesidades de análisis de datos.
