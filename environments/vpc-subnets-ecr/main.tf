#backend
terraform {
	required_version = "> 0.15.0"
	backend "s3" {
		bucket = "oristate"
		key = "ori-app/oristate/vpc-subnets-ecr.tfstate"
		encrypt = true
		region = "us-east-1"
	}
}
#module:
module "vpc_subnets_ecr" {
    source = "../../modules/vpc-subnets-ecr"
    app-region = "us-east-1"
    vpc_cidr = "10.0.0.0/16"
    az2a = "us-east-1a"
    az2b = "us-east-1b"
    az2c = "us-east-1c"
    sub1_cidr = "10.0.0.0/24"
    sub2_cidr = "10.0.1.0/24"
    sub3_cidr = "10.0.2.0/24"
    db_port   = 3306
    db_name   = "oridb2023"
    db_allocated_storage = 5
    db_instance_class = "db.t2.micro"
    db_storage_type   = "gp2"
    db_username   = "oriuser2023"
    db_engine     = "MySQL"
    db_engine_version = "8.0"
    db_parameter_group_name = "default.mysql8.0"
    db_skip_final_snapshot = true 
}

#outputs: will be print on the screen and be use
output "arn" {
    description = "the ecr arn value"
    value = module.vpc_subnets_ecr.arn
}
output "repository_url" {
  description = "the ecr uri"
  value = module.vpc_subnets_ecr.repository_url
}
output "vpc_id" {
  description = "The VPC ID"
  value = module.vpc_subnets_ecr.vpc_id
}
output "subnet1_id" {
  description = "The id of subnet 1"
  value = module.vpc_subnets_ecr.subnet1_id
}
output "subnet2_id" {
  description = "The id of sunet 2 "
  value = module.vpc_subnets_ecr.subnet2_id
}
output "subnet3_id" {
  description = "The id of sunet 3 "
  value = module.vpc_subnets_ecr.subnet3_id
}

#output for database rds
output "db_endpoint" {
	value = module.vpc_subnets_ecr.db_endpoint
}

output "db_address" {
	value = module.vpc_subnets_ecr.db_address
}

output "db_port" {
	value = module.vpc_subnets_ecr.db_port
}

output "db_username" {
	value = module.vpc_subnets_ecr.db_username
}

output "db_password" {
	value = module.vpc_subnets_ecr.db_password
	sensitive = true
}