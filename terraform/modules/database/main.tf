resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.db_identifier}-credentials"
  description             = "Credenciales RDS SQL Server para ${var.db_identifier}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_admin_username
    password = random_password.db_password.result
    engine   = "sqlserver"
    host     = aws_db_instance.mssql.address
    port     = aws_db_instance.mssql.port
    dbname   = var.db_name
  })
}

resource "aws_security_group" "db" {
  name        = "${var.db_identifier}-sg"
  description = "Security group para RDS SQL Server"
  vpc_id      = var.vpc_id
  ingress {
    description = "SQL Server desde la VPC"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.db_identifier}-sg" }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = { Name = "${var.db_identifier}-subnet-group" }
}

resource "aws_db_instance" "mssql" {
  identifier                      = var.db_identifier
  engine                          = "sqlserver-ex"
  engine_version                  = var.db_engine_version
  instance_class                  = var.db_instance_class
  license_model                   = "license-included"
  allocated_storage               = var.db_allocated_storage
  storage_type                    = "gp2"
  storage_encrypted               = true
  username                        = var.db_admin_username
  password                        = random_password.db_password.result
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.db.id]
  publicly_accessible             = false
  port                            = 1433
  backup_retention_period         = var.backup_retention_days
  backup_window                   = "03:00-04:00"
  maintenance_window              = "Mon:04:00-Mon:05:00"
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.db_identifier}-final-snapshot"
  deletion_protection             = var.deletion_protection
  multi_az                        = false
  apply_immediately               = true
  enabled_cloudwatch_logs_exports = ["error"]
  monitoring_interval             = 0
  tags                            = { Name = var.db_identifier }
  lifecycle {
    ignore_changes = [password]
  }
}
