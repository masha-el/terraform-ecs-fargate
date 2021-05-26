variable "vpc_id" {
  description = "using existing vpc that was created before"
  type = string
  default = "vpc-04844244d487da67a"
}

variable "sg_alb_name" {
  description = "Name of the security group application load balancer"
  type = string
  default = "myapp-sg-alb-test"
}

variable "sg_task_name" {
  description = "Name of the security group application load balancer"
  type = string
  default = "myapp-sg-task-test"
}

variable "cluster_name" {
  description = "Name of the cluster for ecs"
  type = string
  default = "myapp-cluster-test"
}

variable "td_name" {
  description = "Name of the task definition"
  type = string
  default = "myapp-td-test"
}

variable "container_td_name" {
  description = "Name of the task definition container"
  type = string
  default = "myapp-container-td-test"
}

variable "container_image" {
  description = "Image number of the existing container image in ECR"
  type = string
  default = "390148573654.dkr.ecr.us-east-2.amazonaws.com/myapp:latest"
  
}

variable "container_port" {
  description = "Number of the container port from Docker app file"
  type = number
  default = 8080
}

variable "lb_name" {
  description = "Name for the load balancer"
  type = string
  default = "myapp-lb-test"
}

variable "alb_target_group" {
  description = "Name for the aooplication load balancer target group"
  type = string
  default = "myapp-alb-tg-test"
}

variable "subnets_lb" {
  description = "list of subnets id's"
  type = list(string)
  default = ["subnet-0fec3a35a6464b2dd","subnet-0ddab5e2677631216"]
}

variable "aws_ecs_service_name" {
  description = "Name of the ECS service"
  type = string
  default = "myapp-service-test"
}

variable "iam_task_role" {
  description = "Name of the IAM task role"
  type = string
  default = "myapp-ecsTaskRole"
}

variable "ecs_task_executionRole" {
  description = "Name of the IAM task execution role"
  type = string
  default = "myapp-ecsTaskExecutionRole"
}

variable "container_name" {
  description = "Name of the container for the load balancer in the service"
  type = string
  default = "myapp-container-test"
}
