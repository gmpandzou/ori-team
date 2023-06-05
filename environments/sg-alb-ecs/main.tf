#backend
terraform {
	required_version = "> 0.15.0"
	backend "s3" {
		bucket = "oristate"
		key = "ori-app/oristate/sg-alb-ecs.tfstate"
		encrypt = true
		region = "us-east-1"
	}
}
#import data form vpc-subnets-ecr modules
data "terraform_remote_state" "vpc_subnets_ecr" {
	backend = "s3"
	config = {
	    bucket = "oristate"
		key = "ori-app/oristate/vpc-subnets-ecr.tfstate"
		region = "us-east-1"
	}
}
locals {
  #networking
  vpc_id			  = data.terraform_remote_state.vpc_subnets_ecr.outputs.vpc_id
  subnet1_id		= data.terraform_remote_state.vpc_subnets_ecr.outputs.subnet1_id
  subnet2_id		= data.terraform_remote_state.vpc_subnets_ecr.outputs.subnet2_id
  subnet3_id		= data.terraform_remote_state.vpc_subnets_ecr.outputs.subnet3_id
  #ecr
  repository_url	= data.terraform_remote_state.vpc_subnets_ecr.outputs.repository_url
  #rds mysql database
  db_host = data.terraform_remote_state.vpc_subnets_ecr.outputs.db_address
  #db_endpoint = data.terraform_remote_state.vpc_subnets_ecr.outputs.db_endpoint
  db_password = data.terraform_remote_state.vpc_subnets_ecr.outputs.db_password
  db_port = data.terraform_remote_state.vpc_subnets_ecr.outputs.db_port
  db_username = data.terraform_remote_state.vpc_subnets_ecr.outputs.db_username
}

#module definition
module "sg_alb_ecs" {
  source = "../../modules/sg-alb-ecs"
  app-region = "us-east-1"
  vpc_id = local.vpc_id
  subnet1_id = local.subnet1_id
  subnet2_id = local.subnet2_id
  subnet3_id = local.subnet3_id
  repository_url = local.repository_url
  #For wordpress
  db_host = local.db_host
  db_name = "oridb2023"
  db_username = local.db_username
  db_password = local.db_password
  db_port = local.db_port
}