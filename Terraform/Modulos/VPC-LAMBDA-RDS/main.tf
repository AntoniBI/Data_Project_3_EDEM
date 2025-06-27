resource "null_resource" "package_lambdas" {
  provisioner "local-exec" {
    working_dir = path.module
    command = <<EOT
    mkdir -p build

    # Empaquetar cada lambda
    for file in $(ls Lambdas/*.py); do
      fname=$(basename "$file" .py)
      echo "Empaquetando lambda: $fname"
      
      # Crear directorio temporal local
      mkdir -p build/tmp_$fname
      cp "$file" build/tmp_$fname/
      cp Lambdas/requirements.txt build/tmp_$fname/
      
      # Instalar dependencias
      pip install -r build/tmp_$fname/requirements.txt -t build/tmp_$fname/ > /dev/null 2>&1
      
      # Crear el zip
      cd build/tmp_$fname
      zip -qr "../$fname.zip" .
      cd ../..
      
      # Limpiar directorio temporal
      rm -rf build/tmp_$fname
      
      echo "Lambda $fname empaquetada correctamente"
    done
    
    echo "Archivos creados en build/:"
    ls -la build/
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
    lambda_files = join(",", [
      filemd5("${path.module}/Lambdas/getProducts.py"),
      filemd5("${path.module}/Lambdas/add.py"),
      filemd5("${path.module}/Lambdas/buy.py"),
      filemd5("${path.module}/Lambdas/requirements.txt")
    ])
  }
}


resource "null_resource" "build_flask_docker" {
  provisioner "local-exec" {
  command = <<EOT
    gcloud auth configure-docker europe-southwest1-docker.pkg.dev -q
    docker build --platform linux/amd64 -t flask ${path.module}
    docker tag flask europe-southwest1-docker.pkg.dev/nice-gate-463112-m8/data-project-3/flask-store
    docker push europe-southwest1-docker.pkg.dev/nice-gate-463112-m8/data-project-3/flask-store
  EOT
}


  triggers = {
    always_run = timestamp()
  }

}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

}



resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"  
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"  
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "subnet1_assoc" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "subnet2_assoc" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public_rt.id
}



resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lambda_sg" {
  vpc_id = aws_vpc.main.id



  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
}


resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "Main DB subnet group"
  }
}

resource "aws_db_parameter_group" "postgresql_datastream" {
  name        = "pg-datastream-csov"
  family      = "postgres16"
  description = "Parameter group for Datastream logical replication"


  parameter {
    name         = "max_replication_slots"
    value        = "10"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_wal_senders"
    value        = "10"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot" 
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = 10
  db_name              = "shopdb"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"
  username             = "postgres_user"
  password             = "password123"
  skip_final_snapshot  = true
  publicly_accessible  = true
  storage_type         = "gp2"
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name = aws_db_parameter_group.postgresql_datastream.name

  
  iam_database_authentication_enabled = true

  tags = {
    Name = "MySQL RDS Instance"
  }
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds_secret_dt3_edem"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = aws_db_instance.mysql.username,
    password = aws_db_instance.mysql.password
  })
  
}


output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}


resource "aws_lambda_function" "get_products" {
  function_name = "getProducts"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "getProducts.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/build/getProducts.zip"

  environment {
    variables = {
      RDS_HOST = aws_db_instance.mysql.endpoint
      RDS_USER = "postgres_user"
      RDS_PASS = "password123"
      RDS_DB   = "shopdb"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id]
    subnet_ids         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  }

  depends_on = [null_resource.package_lambdas]
  timeout    = 30
}

resource "aws_lambda_function" "add_product" {
  function_name = "add"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "add.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/build/add.zip"

  environment {
    variables = {
      RDS_HOST = aws_db_instance.mysql.endpoint
      RDS_USER = "postgres_user"
      RDS_PASS = "password123"
      RDS_DB   = "shopdb"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id]
    subnet_ids         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  }

  depends_on = [null_resource.package_lambdas]
  timeout    = 30
}

resource "aws_lambda_function" "buy_product" {
  function_name = "buy"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "buy.lambda_handler"
  runtime       = "python3.9"
  filename      = "${path.module}/build/buy.zip"

  environment {
    variables = {
      RDS_HOST = aws_db_instance.mysql.endpoint
      RDS_USER = "postgres_user"
      RDS_PASS = "password123"
      RDS_DB   = "shopdb"
    }
  }

  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id]
    subnet_ids         = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  }

  depends_on = [null_resource.package_lambdas]
  timeout    = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

}

resource "aws_iam_role_policy" "lambda_vpc_access" {
  name = "lambda-vpc-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "lambda_secrets_manager_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
resource "aws_iam_role_policy_attachment" "lambda_rds_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "null_resource" "configure_rds_for_datastream" {
  triggers = {
    always_run = "${timestamp()}"  
  }

  provisioner "local-exec" {
    command = <<-EOT
      export PGPASSWORD="${var.db_password}"
      psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "CREATE PUBLICATION ${var.publication} FOR ALL TABLES;"
      psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "SELECT PG_CREATE_LOGICAL_REPLICATION_SLOT('${var.replication_slot}', 'pgoutput');"
      psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "CREATE USER ${var.datastream_user} WITH ENCRYPTED PASSWORD '${var.datastream_password}';"
      psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "GRANT rds_replication TO ${var.datastream_user};"
      psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "GRANT USAGE ON SCHEMA public TO ${var.datastream_user};"
      psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO ${var.datastream_user};"
      psql -h ${var.rds_endpoint} -U ${var.db_username} -d ${var.db_name} -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO ${var.datastream_user};"
    EOT
  }
    depends_on = [
        aws_db_instance.mysql
    ]
}

