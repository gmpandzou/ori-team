# VPC definition
resource "aws_vpc" "ori_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true 

    tags = {
    Name = "ori wordpress app vpc"
    environment = "dev"
	  project = "ori-wordpress-docker-ecr-ecs"
	  terraform = true
    }
}
#Created  Subnet 1
resource "aws_subnet" "subnet1" {
    vpc_id = "${aws_vpc.ori_vpc.id}" #we specify on which VPC to create the subnet
    cidr_block = var.sub1_cidr #"10.0.0.0/24" #we specify the number of IP address available 
    availability_zone = var.az2a # var.dev_AZ1 # we specify the AZ where to create the subnet
    #availability_zone = data.aws_availability_zones.available.names[0]

    map_public_ip_on_launch = true

  tags = {
    Name = "ori public subnet 1"
    environment = "dev"
		project = "ori-wordpress-docker-ecr-ecs"
		terraform = true
  }   
}
#Created Subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id = "${aws_vpc.ori_vpc.id}" #we specify on which VPC to create the subnet
  cidr_block = var.sub2_cidr #"10.0.0.0/24" #we specify the number of IP address available 
  availability_zone = var.az2b # var.dev_AZ1 # we specify the AZ where to create the subnet
    #availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true

    tags = {
      Name = "ori public subnet 2"
      environment = "dev"
		  project = "ori-wordpress-docker-ecr-ecs"
		  terraform = true
    } 
}
#Created Subnet 3
resource "aws_subnet" "subnet3" {
  vpc_id = aws_vpc.ori_vpc.id
  cidr_block = var.sub3_cidr
  availability_zone = var.az2c

  map_public_ip_on_launch = false 

  tags = {
    Name = "ori private subnet 3"
    environment = "dev"
	  project = "ori-wordpress-docker-ecr-ecs"
	  terraform = true
  }
}
#Created Internet Gateway
resource "aws_internet_gateway" "igw1"{
  vpc_id = "${aws_vpc.ori_vpc.id}" 

    tags = {
        Name = "ori internet gateway"
        environment = "dev"
		project = "ori-wordpress-docker-ecr-ecs"
		terraform = true
    }
}
#Created Route Table 
resource "aws_route_table" "pub_rt" {
  vpc_id = "${aws_vpc.ori_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw1.id}"
  }
  
    tags = {
        Name = "ori public route table"
        environment = "dev"
		project = "ori-wordpress-docker-ecr-ecs"
		terraform = true
    }
}
#Created Association for subnet and Route Table
resource "aws_route_table_association" "rta_subnet1" {
    route_table_id = "${aws_route_table.pub_rt.id}"
    subnet_id = "${aws_subnet.subnet1.id}"
    depends_on = [
      aws_route_table.pub_rt, aws_subnet.subnet1
    ]
}
resource "aws_route_table_association" "rta_subnet2" {
    route_table_id = "${aws_route_table.pub_rt.id}"
    subnet_id = "${aws_subnet.subnet2.id}"
    depends_on = [
      aws_route_table.pub_rt, aws_subnet.subnet2
    ]
}
resource "aws_route_table_association" "rta_subnet3" {
    route_table_id = "${aws_route_table.pub_rt.id}"
    subnet_id = "${aws_subnet.subnet3.id}"
    depends_on = [
      aws_route_table.pub_rt, aws_subnet.subnet3
    ]
}
#-added--network acl: 01 nacl = for 01 subnet
resource "aws_network_acl" "orinacl1" {
  vpc_id = aws_vpc.ori_vpc.id
  #outbound
  egress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = var.sub1_cidr
    #cidr_block = ["${var.sub1_cidr}", "${var.sub2_cidr}", "${var.sub3_cidr}"] 
    from_port = 0
    to_port = 65535

  }
  #inbound
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = var.sub1_cidr
    #cidr_block = ["${var.sub1_cidr}", "${var.sub2_cidr}", "${var.sub3_cidr}"]
    from_port = 0
    to_port = 65535
  }
  
}
resource "aws_network_acl" "orinacl2" {
  vpc_id = aws_vpc.ori_vpc.id
  #outbound
  egress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = var.sub2_cidr
    #cidr_block = ["${var.sub1_cidr}", "${var.sub2_cidr}", "${var.sub3_cidr}"] 
    from_port = 0
    to_port = 65535

  }
  #inbound
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = var.sub2_cidr
    #cidr_block = ["${var.sub1_cidr}", "${var.sub2_cidr}", "${var.sub3_cidr}"]
    from_port = 0
    to_port = 65535
  }
}
resource "aws_network_acl" "orinacl3" {
  vpc_id = aws_vpc.ori_vpc.id
  #outbound
  egress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = var.sub3_cidr
    #cidr_block = ["${var.sub1_cidr}", "${var.sub2_cidr}", "${var.sub3_cidr}"] 
    from_port = 0
    to_port = 65535

  }
  #inbound
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = var.sub3_cidr
    #cidr_block = ["${var.sub1_cidr}", "${var.sub2_cidr}", "${var.sub3_cidr}"]
    from_port = 0
    to_port = 65535
  }
  
}
# ecr repository definition
resource "aws_ecr_repository" "ecr1_repo" {
  name = "ecr1-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
   }
}
# security group for rds mysql database
resource "aws_security_group" "rds_sg" {
  name = "rds-sg"
  description = "Allow inbound access in port 3306 only"
  vpc_id = aws_vpc.ori_vpc.id

  ingress {
    protocol = "tcp"
    from_port = var.db_port
    to_port = var.db_port
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# rds mysql database subnet group
resource "aws_db_subnet_group" "rds_subnet" {
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id, aws_subnet.subnet3.id]
  tags = {
    Name = "Ori rds mysql database subnet group"
    environment = "dev"
    terraform = true
    project = "card-220064-docker-wp-ecs-ecr-rds"
  }
}
# rds mysql database 
resource "aws_db_instance" "ori_rds" {
  allocated_storage      = var.db_allocated_storage
  storage_type           = var.db_storage_type
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  name                   = var.db_name
  username               = var.db_username
  password               = "Mp$ndzou1989"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.id 
  skip_final_snapshot     = var.db_skip_final_snapshot
  availability_zone      = var.az2a #may cause issues:because all specify subnets are not in the same az
  publicly_accessible = true

 #tags = {
    #Name = "Ori rds mysql database"
    #environment = "dev"
    #terraform = true
    #project = "card-220064-docker-wp-ecs-ecr-rds"
  #}
}