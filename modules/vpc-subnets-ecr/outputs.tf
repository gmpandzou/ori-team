output "arn" {
    description = "the ecr arn value"
    value = aws_ecr_repository.ecr1_repo.arn
}

output "repository_url" {
  description = "the ecr uri"
  value = aws_ecr_repository.ecr1_repo.repository_url
}

output "vpc_id" {
  description = "The VPC ID"
  value = aws_vpc.ori_vpc.id
}

output "subnet1_id" {
  description = "The id of subnet 1"
  value = aws_subnet.subnet1.id
}

output "subnet2_id" {
  description = "The id of sunet 2 "
  value = aws_subnet.subnet2.id
}

output "subnet3_id" {
  description = "The id of sunet 2 "
  value = aws_subnet.subnet3.id
}

output "db_endpoint" {
  description = "The database endpoint for connection"
  value       = aws_db_instance.ori_rds.endpoint
}

output "db_address" {
  description = "The database address for connection"
  value       = aws_db_instance.ori_rds.address
}

output "db_port" {
  description = "The database port for connection"
  value       = aws_db_instance.ori_rds.port
}

output "db_username" {
  description = "The database username for connection"
  value       = var.db_username
}

output "db_password" {
  description = "The database password for connection"
  value       = aws_db_instance.ori_rds.password
  sensitive   = true
}