provider "aws" {
  region = var.region
}

################################################################################
# Security Groups
################################################################################

resource "aws_security_group" "main" {
  name   = var.sg_name
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = var.container_port
    to_port          = var.container_port
    cidr_blocks      = var.cidr_blocks
    ipv6_cidr_blocks = var.ipv6_cidr_blocks
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = var.cidr_blocks
    ipv6_cidr_blocks = var.ipv6_cidr_blocks
  }

  tags = {
    Name = var.sg_name
  }
}

################################################################################
# Cluster
################################################################################

resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  tags = {
    Name = var.cluster_name
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.td_name
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name   = var.container_name
    image  = var.container_image
    memory = var.memory
    cpu    = var.cpu
    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]
  }])

  tags = {
    Name = var.td_name
  }
}

################################################################################
# Load Balancer 
################################################################################

resource "aws_lb" "main" {
  name               = var.lb_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = aws_security_group.main.*.id
  subnets            = var.subnets_lb

  enable_deletion_protection = false

  tags = {
    Name = var.lb_name
  }
}

resource "aws_alb_target_group" "main" {
  name_prefix = "ALB-TG"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  depends_on  = [aws_lb.main]
  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/"
    unhealthy_threshold = "3"
    healthy_threshold   = "6"
    timeout             = "10"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200,301,302"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }
}

################################################################################
# Service
################################################################################

resource "aws_ecs_service" "main" {
  name            = var.service_name
  task_definition = aws_ecs_task_definition.main.arn
  cluster         = aws_ecs_cluster.main.id
  desired_count   = 2
  launch_type     = var.launch_type
  # depends_on      = [aws_alb_target_group.main]

  network_configuration {
    subnets          = var.subnets_lb
    security_groups  = aws_security_group.main.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = var.container_name
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

###added
resource "aws_iam_role_policy_attachment" "ecs-task-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
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

###added
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


