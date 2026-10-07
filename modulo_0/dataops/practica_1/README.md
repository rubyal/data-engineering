# Data Platform — Terraform Scaffold

Esqueleto de Infraestructura como Código (IaC) para una plataforma de datos en AWS. Incluye validación local y en CI, backend remoto S3 con locking en DynamoDB (state aislado por ambiente), un módulo de **Amazon Kinesis Data Streams** y la base del módulo de **Amazon Managed Service for Apache Flink**.

## Estructura

```text
practica_1/
├── .github/workflows/terraform.yml   # CI: fmt -check + init -backend=false + validate
├── backend/                          # Config parcial del backend, una por ambiente
│   ├── dev.hcl
│   ├── stage.hcl
│   └── prod.hcl
├── bootstrap/                        # Crea el bucket S3 y la tabla DynamoDB del state
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   └── variables.tf
├── modules/
│   ├── kinesis/                      # Kinesis Data Stream (PROVISIONED, cifrado KMS)
│   └── flink/                        # Base de Managed Service for Apache Flink
├── backend.tf                        # backend "s3" {} (valores en backend/*.hcl)
├── main.tf                           # Prefijo estándar + composición de módulos
├── outputs.tf
├── provider.tf                       # Versiones mínimas + provider AWS + default_tags
├── terraform.tfvars                  # Valores del ambiente dev
├── variables.tf
├── .gitignore
└── README.md
```

> `.terraform/` no se versiona (se genera con `terraform init`). `.terraform.lock.hcl` **sí** se versiona para fijar la versión del provider.

## Requisitos

- Terraform CLI `>= 1.6.0, < 2.0.0`
- AWS CLI con un perfil o rol autorizado (`aws sts get-caller-identity` para verificar)
- Git

## 1. Inicializar el repositorio

```bash
cd practica_1
git init -b main
git add .
git commit -m "chore: scaffold inicial de Terraform"
git remote add origin git@github.com:<usuario>/<repo>.git
git push -u origin main
```

> GitHub Actions solo descubre workflows en `.github/workflows/` **en la raíz del repositorio**. Si `practica_1` no es la raíz, mueve esa carpeta a la raíz y ajusta `directory` en la matriz del workflow.

## 2. Validar el scaffold (sin tocar AWS)

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

El mismo trío corre en CI para la raíz y para `bootstrap/`. `terraform plan` requiere credenciales AWS y un backend inicializado (secciones 3 y 4).

## 3. Backend remoto: S3 + DynamoDB

El backend debe existir antes de poder usarse, por eso se crea desde un stack aparte (`bootstrap/`, con state local).

```bash
cd bootstrap
# Edita terraform.tfvars: state_bucket_name debe ser globalmente único
terraform init
terraform apply
terraform output
cd ..
```

Después, asegúrate de que `bucket` en `backend/dev.hcl`, `stage.hcl` y `prod.hcl` coincida con el bucket creado. Cada ambiente usa una key distinta:

```text
data-platform/dev/terraform.tfstate
data-platform/stage/terraform.tfstate
data-platform/prod/terraform.tfstate
```

## 4. Trabajar con un ambiente

```bash
# dev (valores en terraform.tfvars)
terraform init -reconfigure -backend-config=backend/dev.hcl
terraform plan

# stage / prod: mismo código, otro state y otro valor de `environment`
terraform init -reconfigure -backend-config=backend/stage.hcl
terraform plan -var="environment=stage"
```

Siempre usa `-reconfigure` al cambiar de ambiente: así nunca se opera sobre el state equivocado.

> Nota: `dynamodb_table` está marcado como deprecado desde Terraform 1.10 a favor de `use_lockfile = true` (lock nativo en S3). Se mantiene DynamoDB por ser el estándar más extendido; puede migrarse sin cambiar la estructura.

## 5. Convención de nombres y tags

Patrón de nombres:

```text
<proyecto>-<ambiente>-<servicio>-<recurso>
```

Se calcula **una sola vez** en `main.tf` (`local.name_prefix = "${var.project_name}-${var.environment}"`) y se pasa a cada módulo como `name_prefix`. Ejemplos con los valores de `terraform.tfvars`:

- `data-platform-dev-kinesis-events`
- `data-platform-dev-flink-stream-processor`

Tags: el provider aplica `Project`, `Environment` y `ManagedBy = "Terraform"` a todos los recursos mediante `default_tags`; cada módulo añade `Component` (p. ej. `kinesis`). Los módulos nuevos deben seguir el mismo patrón.

## 6. Módulos

**`modules/kinesis`** crea un stream `PROVISIONED` con cifrado KMS (`alias/aws/kinesis`). Inputs: `name_prefix`, `shard_count`, `retention_hours`. Outputs: `stream_name`, `stream_arn`.

**`modules/flink`** define la interfaz (`name_prefix`, `kinesis_stream_arn`) y reserva el nombre `<prefijo>-flink-stream-processor`. Aún no crea la aplicación porque faltan decisiones que no deben inventarse en un scaffold: artefacto en S3, runtime, rol IAM de mínimo privilegio, checkpoints, logging y propiedades de la app. Es el punto de partida del siguiente ejercicio.

## 7. ¿Por qué se separan los archivos?

Terraform carga todos los `.tf` de un directorio como una sola configuración, así que la separación no afecta la ejecución: es una decisión de **mantenibilidad**.

| Archivo | Responsabilidad | Por qué separado |
|---|---|---|
| `provider.tf` | Versión de Terraform, providers y tags comunes | Cambia rara vez; se revisa al actualizar versiones |
| `backend.tf` | Declara dónde vive el state | Se aísla del código de recursos; los valores van por ambiente |
| `variables.tf` | Interfaz de entrada con tipos, descripciones y validaciones | Es el "contrato" que otros leen primero |
| `main.tf` | Composición de módulos y recursos | Los diffs de infraestructura quedan concentrados aquí |
| `outputs.tf` | Valores que consumen otros stacks o pipelines | Hace explícito qué se expone |
| `terraform.tfvars` | Valores concretos de un ambiente | Separa código de configuración |
| `bootstrap/` | Crea el backend antes de usarlo | Resuelve el problema del huevo y la gallina |
| `modules/` | Componentes reutilizables | Kinesis y Flink crecen sin inflar `main.tf` |

Un único `main.tf` funcionaría al inicio, pero a medida que se sumen Kinesis, Flink e IAM se volvería difícil de revisar, generaría conflictos de merge y mezclaría configuración, interfaz y recursos.

## 8. Reglas de seguridad

- **Nunca** subir `*.tfstate` ni `.terraform/`: el state puede contener secretos en texto plano y un archivo local rompe el trabajo en equipo (por eso `.gitignore` los excluye y el state vive en S3 cifrado con versionado).
- Las variables siempre declaran `type` y `description`.
- No guardar credenciales en `*.tfvars`; usar perfiles/roles de AWS.
