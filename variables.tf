variable "region" {
  description = "Region name"
  type        = string
}

variable "sg_name" {
  description = "Name of the security group for the application"
  type        = string
}

variable "cidr_blocks" {
  description = "List of CIDR blocks for ipv4"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ipv6_cidr_blocks" {
  description = "List of CIDR blocks for ipv6"
  type        = list(string)
  default     = ["::/0"]
}

variable "vpc_id" {
  description = "using existing vpc that was created before"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster for our application"
  type        = string
}

variable "td_name" {
  description = "Name of the task definition"
  type        = string
}

variable "network_mode" {
  description = "Network mode name for FARGATE"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "Compatibilities list"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "Number for CPU"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Number of memory"
  type        = number
  default     = 1024
}

variable "container_name" {
  description = "Name of the application image container in ECR"
  type        = string
}

variable "container_image" {
  description = "Image number of the existing container image in ECR"
  type        = string
}

variable "container_port" {
  description = "Number of the container port from Docker app file"
  type        = number
}

variable "host_port" {
  description = "Port number which connects to container port"
  type        = number
  default     = 80
}

variable "lb_name" {
  description = "Name for the load balancer"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer, default application for FARGATE"
  type        = string
  default     = "application"
}

variable "subnets_lb" {
  description = "list of subnets id's for load balancer"
  type        = list(string)
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}
variable "launch_type" {
  description = "Name of the ECS service launch type"
  type        = string
}

variable "iam_task_role" {
  description = "Name of the IAM task role"
  type        = string
  default     = "myapp-ecsTaskRole"
}

variable "ecs_task_executionRole" {
  description = "Name of the IAM task execution role"
  type        = string
  default     = "myapp-ecsTaskExecutionRole"
}


