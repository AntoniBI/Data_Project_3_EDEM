variable "gcp_region" {
  description = "Region for the resources"
  type        = string
  default     = "europe-southwest1"
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "nice-gate-463112-m8"
}

variable "artifact_repo_id" {
  description = "Artifact repository ID"
  type        = string
  default     = "data-project-3"
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
}

