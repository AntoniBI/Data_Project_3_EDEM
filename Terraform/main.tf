terraform {
  # MEJORA: Especificar versión mínima de Terraform
  required_version = ">= 1.0"
  
  # MEJORA: Versionar providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  
  backend "gcs" {
    bucket = "data-project3-terraform-state"
    prefix = "terraform/state"    
    # MEJORA: Añadir encryption = true para el state
  }
}

# MEJORA 2: Añadir configuración de providers
provider "aws" {
  region = var.aws_region
  # MEJORA: Configurar default tags para todos los recursos
  default_tags {
    tags = {
      Project     = "data-project-3"
      Environment = "dev"
      ManagedBy   = "terraform"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

module "ArtifactRegistry" {
  source = "./Modulos/ArtifactRegistry"
  artifact_repo_id = var.artifact_repo_id
  aws_region = var.aws_region
}

module "VPC-LAMBDA-RDS" {
  source = "./Modulos/VPC-LAMBDA-RDS"
  artifact_repo_id = var.artifact_repo_id
  aws_region = var.aws_region
  db_password = var.db_password
  db_username = var.db_username
  db_name = var.db_name
  publication = var.publication
  replication_slot = var.replication_slot
  datastream_user = var.datastream_user
  datastream_password = var.datastream_password
  rds_endpoint = var.rds_endpoint
  
  # MEJORA 3: Añadir depends_on explícito si es necesario
}

module "DataStream" {
  source = "./Modulos/DataStream"
  gcp_project_id = var.gcp_project_id
  gcp_region = var.gcp_region
  aws_region = var.aws_region
  source_connection_profile_id = var.source_connection_profile_id
  replication_slot = var.replication_slot
  publication = var.publication
  destination_connection_profile_id = var.destination_connection_profile_id
  
  # MEJORA 4: El DataStream debería depender del módulo VPC-LAMBDA-RDS
  depends_on = [module.VPC-LAMBDA-RDS]
}

# MEJORA 5: Añadir outputs importantes para referencia
output "vpc_lambda_rds_outputs" {
  description = "Outputs from VPC-LAMBDA-RDS module"
  value       = module.VPC-LAMBDA-RDS
  sensitive   = true
}

output "datastream_outputs" {
  description = "Outputs from DataStream module"
  value       = module.DataStream
}
