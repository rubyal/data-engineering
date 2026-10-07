# Data Platform — Terraform Scaffold

Esqueleto inicial de Infraestructura como Código (IaC) para una plataforma de datos en AWS. Preparado para incorporar **Amazon Kinesis Data Streams** y **Amazon Managed Service for Apache Flink**.

## Estructura

```text
data-platform-terraform/
├── .gitignore         # Excluye state, cachés, planes y valores locales sensibles
├── provider.tf        # Versión de Terraform, provider de AWS y tags comunes
├── main.tf            # Recursos principales y convenciones locales
├── variables.tf       # Parámetros de entrada y validaciones
├── outputs.tf         # Valores exportados
├── terraform.tfvars   # Valores de ejemplo no sensibles (ambiente dev)
└── README.md          # Instrucciones y decisiones de diseño
```

## Requisitos

- Terraform CLI >= 1.6 y < 2.0.
- Cuenta de AWS y credenciales configuradas mediante perfil o rol IAM (no colocar claves en archivos `.tf`).
- Git instalado. Para provisionamiento real, permisos IAM limitados a los recursos del proyecto.

## Inicializar y validar

```bash
cd data-platform-terraform
aws sts get-caller-identity   # Opcional: verifica tu identidad AWS
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply              # Opcional: el scaffold aún no crea recursos AWS
terraform output
```

`terraform init` descargará providers y generará `.terraform.lock.hcl`. **Sí versiona `.terraform.lock.hcl`** para mantener versiones reproducibles del provider.

### Configuración

`terraform.tfvars` contiene únicamente valores de ejemplo no sensibles:

```hcl
region       = "us-east-1"
project_name = "data-platform"
environment  = "dev"
```

No agregues secretos a los `.tfvars`; usa IAM Roles, AWS Secrets Manager o variables sensibles de un pipeline. Para un ambiente real, separa su configuración y su estado de Terraform.

## Convención de nombres

Patrón: `<proyecto>-<ambiente>-<servicio>-<recurso>` (minúsculas, números y guiones).

Ejemplos:

- `data-platform-dev-kinesis-events`
- `data-platform-dev-flink-transform`
- `data-platform-prod-s3-raw` (los buckets S3 también deben tener nombres globalmente únicos).

Todos los recursos compatibles heredan tags `Project`, `Environment` y `ManagedBy` a través de `default_tags` del provider.

## ¿Por qué separar los archivos?

- **provider.tf:** centraliza compatibilidad y configuración de AWS.
- **variables.tf:** expone la interfaz del proyecto y valida entradas.
- **main.tf:** concentra recursos y referencias entre ellos, sin mezclar detalles de versiones.
- **outputs.tf:** publica identificadores para integración con otros módulos o pipelines.
- **terraform.tfvars:** separa la configuración de cada despliegue del código reutilizable.

Esta separación reduce el acoplamiento, facilita revisiones de código y permite que varias personas trabajen sobre el mismo repositorio. Terraform lee automáticamente todos los archivos `.tf` del mismo directorio: no depende del nombre del archivo para el orden de ejecución.

## Crear y vincular el repositorio remoto

Crea primero un repositorio **vacío** en GitHub o GitLab (sin inicializar README). Después:

```bash
git init
git branch -M main
git add .
git commit -m "chore: initialize AWS data platform Terraform scaffold"
git remote add origin git@github.com:TU_USUARIO/data-platform-terraform.git
# Alternativa GitLab: git@gitlab.com:TU_USUARIO/data-platform-terraform.git
git push -u origin main
```

Reemplaza la URL remota por la de tu repositorio. El vínculo y el push requieren tu acceso Git; no se realizan automáticamente al descargar el scaffold.

## Siguientes pasos antes de producción

1. Configurar un **backend remoto S3** para el state con control de acceso, cifrado, versionado y locking compatible con la versión de Terraform; evitar el state local compartido.
2. Aislar los estados de `dev`, `stage` y `prod`, preferiblemente con directorios raíz y pipelines separados.
3. Crear módulos reutilizables para Kinesis, Flink, IAM, observabilidad y seguridad.
4. Añadir ejecución automatizada de `terraform fmt -check`, `terraform validate` y `terraform plan` en CI.
5. Gestionar credenciales con IAM Identity Center, perfiles o roles de CI/CD; no incluir access keys en Git.

> Nota: este scaffold no provisiona recursos AWS todavía. El output de prefijo funciona incluso sin recursos, y sirve para comprobar la configuración inicial.
