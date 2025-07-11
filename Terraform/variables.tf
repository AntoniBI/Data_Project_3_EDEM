variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "nice-gate-463112-m8"
  # MEJORA: No usar hardcoded project IDs, usar data sources o variables sin default
}

variable "gcp_region" {
  description = "Region for GCP resources"
  type        = string
  default     = "europe-southwest1"
}

variable "artifact_repo_id" {
  description = "Artifact repository ID"
  type        = string
  default     = "data-project-3"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

# MEJORA 2: ¡CRÍTICO! - Nunca hardcodear passwords en archivos de configuración
variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  default     = "password123"  # PELIGRO: Password débil y hardcodeado
  sensitive   = true           # MEJORA: Añadir sensitive = true
  # MEJORA: Usar AWS Secrets Manager o generar password aleatoriamente
}

variable "db_username" {
  description = "Username for the RDS instance"
  type        = string
  default     = "postgres_user"  
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
  default     = "shopdb"
}

variable "publication" {
  description = "Publication for PostgreSQL source"
  type        = string
  default     = "datastream_publication"
}

variable "replication_slot" {
  description = "Replication slot for PostgreSQL source"
  type        = string
  default     = "datastream_slot"
}

# MEJORA 3: Otro password hardcodeado - mismo problema crítico de seguridad
variable "datastream_user" {
  description = "User for Datastream logical replication"
  type        = string
  default     = "datastream_user"
}

variable "datastream_password" {
  description = "Password for Datastream logical replication user"
  type        = string
  default     = "datastream_password"  # PELIGRO: Password hardcodeado
  sensitive   = true                   # MEJORA: Añadir sensitive = true
}

# MEJORA 4: Usar data source para obtener el endpoint dinámicamente
variable "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  type        = string
  default     = "terraform-20250627075830662500000001.chs8ig0oc6qv.eu-central-1.rds.amazonaws.com"
  # MEJORA: Usar data "aws_db_instance" o output del módulo RDS
}

# MEJORA 5: Usar locals o data sources para construir estos ARNs dinámicamente
variable "source_connection_profile_id" {
  description = "ID of the source connection profile"
  type        = string
  default = "projects/nice-gate-463112-m8/locations/europe-southwest1/connectionProfiles/postgresql-source"
  # MEJORA: Construir dinámicamente con interpolation
}

variable "destination_connection_profile_id" {
  description = "ID of the destination connection profile"
  type        = string
  default = "projects/nice-gate-463112-m8/locations/europe-southwest1/connectionProfiles/bigquery-destination"
  # MEJORA: Construir dinámicamente con interpolation
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true  # MEJORA: Añadir sensitive = true para credenciales
  # MEJORA: Usar IAM roles en lugar de access keys cuando sea posible
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true  # MEJORA: Añadir sensitive = true para credenciales
}
