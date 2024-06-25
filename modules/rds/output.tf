output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.rds.endpoint
}

output "db_instance_address" {
  description = "The connection endpoint"
  value       = aws_db_instance.rds.address
}
