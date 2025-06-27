variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "nice-gate-463112-m8"
}

variable "gcp_region" {
  description = "Region for the resources"
  type        = string
  default     = "europe-southwest1"
}

variable "aws_region" {
  description = "AWS Region for the resources"
  type        = string
  default     = "eu-central-1"
}

variable "source_connection_profile_id" {
  description = "ID of the source connection profile"
  type        = string
  default = "projects/nice-gate-463112-m8/locations/europe-southwest1/connectionProfiles/postgresql-source"
}

variable "replication_slot" {
  description = "Replication slot for PostgreSQL source"
  type        = string
  default     = "datastream_slot"
  
}

variable "publication" {
  description = "Publication for PostgreSQL source"
  type        = string
  default     = "datastream_publication"
}

variable "destination_connection_profile_id" {
  description = "ID of the destination connection profile"
  type        = string
  default = "projects/nice-gate-463112-m8/locations/europe-southwest1/connectionProfiles/bigquery-destination"
  
}