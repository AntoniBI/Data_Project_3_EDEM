variable "gcp_project_id" {
  default = "nice-gate-463112-m8"
}

variable "gcp_region" {
  default = "europe-southwest1"
}

variable "artifact_repo_id" {
  default = "data-project-3"
}

variable "aws_region" {
  default = "eu-central-1"
  
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  default     = "password123"
  
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

variable "datastream_user" {
  description = "User for Datastream logical replication"
  type        = string
  default     = "datastream_user"
}

variable "datastream_password" {
  description = "Password for Datastream logical replication user"
  type        = string
  default     = "datastream_password"
}

variable "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  type        = string
  default     = "terraform-20250627075830662500000001.chs8ig0oc6qv.eu-central-1.rds.amazonaws.com"
}

variable "source_connection_profile_id" {
  description = "ID of the source connection profile"
  type        = string
  default = "projects/nice-gate-463112-m8/locations/europe-southwest1/connectionProfiles/postgresql-source"
}

variable "destination_connection_profile_id" {
  description = "ID of the destination connection profile"
  type        = string
  default = "projects/nice-gate-463112-m8/locations/europe-southwest1/connectionProfiles/bigquery-destination"
}
