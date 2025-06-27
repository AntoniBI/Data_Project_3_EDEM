terraform {
  backend "gcs" {
    bucket = "data-project3-terraform-state"
    prefix = "terraform/state"    
  }
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
}
