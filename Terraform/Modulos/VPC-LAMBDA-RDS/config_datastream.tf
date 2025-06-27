# resource "null_resource" "configure_rds_for_datastream" {
#   triggers = {
#     always_run = "${timestamp()}"  
#   }

#   provisioner "local-exec" {
#     command = <<-EOT
#       export PGPASSWORD="${var.db_password}"
#       psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "CREATE PUBLICATION ${var.publication} FOR ALL TABLES;"
#       psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('${var.replication_slot}', 'pgoutput');"
#       psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "CREATE USER ${var.datastream_user} WITH ENCRYPTED PASSWORD '${var.datastream_password}';"
#       psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "GRANT rds_replication TO ${var.datastream_user};"
#       psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "GRANT USAGE ON SCHEMA public TO ${var.datastream_user};"
#       psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${var.datastream_user};"
#       psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ${var.datastream_user};"
#     EOT
#   }
#     depends_on = [
#         aws_db_instance.mysql
#     ]
# }
