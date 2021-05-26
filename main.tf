provider "aws" {
  region = "us-east-2"
}

################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "alb" {
  name   = var.sg_alb_name
  vpc_id = var.vpc_id
 
  ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 80
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name   = var.sg_task_name
  vpc_id = var.vpc_id
 

  ingress {
   protocol         = "tcp"
   from_port        = 0
   to_port          = 65535
   security_groups  = aws_security_group.alb.*.id
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
}

################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.td_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
   name        = var.container_td_name
   image       = var.container_image
   memory      = 512
   portMappings = [{
     protocol      = "tcp"
     containerPort = var.container_port
     hostPort      = var.container_port
    }]
  }])
}

################################################################################
# Load Balancer 
################################################################################

resource "aws_lb" "main" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_security_group.alb.*.id
  subnets            = var.subnets_lb
 
  enable_deletion_protection = false
}
 
resource "aws_alb_target_group" "main" {
  name        = var.alb_target_group
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
 
  health_check {
   matcher             = "200"
   path                = "/"
  }
}

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.main.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }
}

################################################################################
# Service
################################################################################

resource "aws_ecs_service" "main" {
 name                               = var.aws_ecs_service_name
 task_definition                    = aws_ecs_task_definition.main.arn
 cluster                            = aws_ecs_cluster.main.id
 desired_count                      = 2
 launch_type                        = "FARGATE"
 depends_on                         = [aws_lb_listener.web-listener]
 
 network_configuration {
   subnets            = var.subnets_lb
   security_groups    = aws_security_group.alb.*.id
 }

 load_balancer {
   target_group_arn = aws_alb_target_group.main.arn
   container_name   = var.container_td_name
   container_port   = var.container_port
 }
 
 lifecycle {
   ignore_changes = [task_definition, desired_count]
 }
}

################################################################################
# IAM Roles
################################################################################

resource "aws_iam_role" "ecs_task_role" {
  name = var.iam_task_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = var.ecs_task_executionRole
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}