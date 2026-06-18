output "db_endpoint" { value = aws_db_instance.mssql.endpoint }
output "db_address" { value = aws_db_instance.mssql.address }
output "db_port" { value = aws_db_instance.mssql.port }
output "db_identifier" { value = aws_db_instance.mssql.identifier }
output "db_security_group_id" { value = aws_security_group.db.id }
output "db_secret_arn" { value = aws_secretsmanager_secret.db_password.arn }
output "db_secret_name" { value = aws_secretsmanager_secret.db_password.name }
