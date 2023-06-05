variable "app-region" {
  description = "The region in AWS where to deploy the resource"
  type = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = string
  description = "The vpc address"
  default = "10.0.0.0/16"
}

variable "az2a" {
  description = "Availability zone"
  type = string
  default = "us-east-1a"
}

variable "az2b" {
  description = "Availability zone"
  type = string
  default = "us-east-1b"
}

variable "az2c" {
  description = "Availability zone"
  type = string
  default = "us-east-1c"
}

variable "sub1_cidr" {
  description = "The cidr bloc of subnet 1"
  type = string
  default = "10.0.0.0/24"
}

variable "sub2_cidr" {
  description = "The cidr bloc of subnet 2"
  type = string
  default = "10.0.1.0/24"
}

variable "sub3_cidr" {
  description = "The cidr bloc of subnet 3"
  type = string
  default = "10.0.2.0/24"
}

variable "db_port" {
  type = number
  default = 3306
  description = "TCP port for database"
}

variable "db_allocated_storage" {
  type = number
  description = "The allocated storage in Gibibytes " 
}

variable "db_name" {
  type = string
  description = "The database name" 
}

variable "db_instance_class" {
  type        = string
  description = "The instance type of the RDS instance"
}

variable "db_storage_type" {
  type        = string
  description = "One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD)"
}

variable "db_username" {
  type        = string
  description = "Username for the master DB user"
}

variable "db_engine" {
  type        = string
  description = "The database engine to use"
}

variable "db_engine_version" {
  type        = string
  description = "The engine version to use (https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html)"
}

variable "db_parameter_group_name" {
  type        = string
  description = "Name of the DB parameter group to associate"
}

variable "db_skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
}