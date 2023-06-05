#cluster creation
resource "aws_ecs_cluster" "ori_wp_cluster" {
  name = "Ori-docker-wordpress-cluster" # Naming the cluster
}
#task definition
resource "aws_ecs_task_definition" "ori_wp_ecs_task" {
  family                   = "ori-wp-docker-container" # Naming our first task
  container_definitions    = <<TASK_DEFINITION
  [
    {
      "cpu": 256,
      "environment": [
        {
          "name": "WORDPRESS_DB_HOST",
          "value": "${var.db_host}"
        },
        {
          "name": "WORDPRESS_DB_USER",
          "value": "${var.db_username}"
        },
        {
          "name": "WORDPRESS_DB_PASSWORD",
          "value": "${var.db_password}"
        },
        {
          "name": "WORDPRESS_DB_NAME",
          "value": "${var.db_name}"
        },
        {
          "name": "WORDPRESS_DB_SITE_TITLE",
          "value": "${var.wordpress_site_title}"
        },
        {
          "name": "WORDPRESS_ADMIN_USER",
          "value": "${var.wordpress_admin_user}"
        },
        {
          "name": "WORDPRESS_ADMIN_PASSWORD",
          "value": "${var.wordpress_admin_password}"
        },
        {
          "name": "WORDPRESS_ADMIN_EMAIL",
          "value": "${var.wordpress_admin_email}"
        },
        {
          "name": "MYSQL_ENV_MYSQL_PASSWORD",
          "value": "${var.db_password}"
        }
      ],
      "essential": true,
      "image": "${var.repository_url}",
      "memory": 512,
      "name": "ori-wp-docker-container",
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
    }
  ]
  TASK_DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecs_Task_Execution_Role.arn}"
}
  
#iam role --ok
resource "aws_iam_role" "ecs_Task_Execution_Role" {
  name               = "ecs-Task-Execution-Role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}
# --ok
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
# --ok
resource "aws_iam_role_policy_attachment" "ecs_Task_Execution_Role_policy" {
  role       = "${aws_iam_role.ecs_Task_Execution_Role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
#
resource "aws_alb" "ori_wp_alb" {
  depends_on = [
    aws_security_group.alb_sg
  ]
  name               = "Ori-wp-alb" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${var.subnet1_id}",
    "${var.subnet2_id}",
    "${var.subnet3_id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.alb_sg.id}"]
}
# Creating a security group for the load balancer:
resource "aws_security_group" "alb_sg" {
    vpc_id = var.vpc_id
  ingress {
    from_port   = 80 # Allowing traffic in from port 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#
resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "${var.vpc_id}" #"${aws_default_vpc.default_vpc.id}" # Referencing the default VPC
  #added  
  health_check {
    matcher = "200,301,302"
    path = "/"
  }
}
#
resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_alb.ori_wp_alb.arn}" # Referencing our load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our tagrte group
  }
}

resource "aws_ecs_service" "ori_wp_service" {
  depends_on = [
    aws_security_group.service_security_group, aws_ecs_cluster.ori_wp_cluster, aws_ecs_task_definition.ori_wp_ecs_task, aws_lb_target_group.target_group
  ]
  name            = "ori-wp-service"  # Naming our first service
  cluster         = "${aws_ecs_cluster.ori_wp_cluster.id}"             # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.ori_wp_ecs_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Setting the number of containers to 1

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # Referencing our target group
    container_name   = "${aws_ecs_task_definition.ori_wp_ecs_task.family}"
    container_port   = 80 # Specifying the container port
  }

  network_configuration {
    subnets          = ["${var.subnet1_id}", "${var.subnet2_id}", "${var.subnet3_id}"]
    assign_public_ip = true   # Providing our containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Setting the security group
  }

  tags = {
    name = "ori-ecs-service"
    project = "ori"
    terraform = true

  }
}

resource "aws_security_group" "service_security_group" {
    vpc_id = var.vpc_id
    depends_on = [
     aws_security_group.alb_sg
    ]

  ingress {
    from_port = 0 #previuous = 0
    to_port   = 0 # previuos = 0
    protocol  = "-1" #previuous = -1
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.alb_sg.id}"]
  }
  #open all ports for the outbound connection
  egress {
    from_port   = 0 #previuos = 0
    to_port     = 0 # previuos = 0
    protocol    = "-1" # previous = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}