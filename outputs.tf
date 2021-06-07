#-----------------
# AWS ECS SERVICE
#-----------------
output "aws_ecs_service_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service."
  value       = aws_ecs_service.main.id
}

output "aws_ecs_service_name" {
  description = "The name of the service."
  value       = aws_ecs_service.main.name
}

output "aws_ecs_cluster" {
  description = "The Amazon Resource Name (ARN) of cluster which the service runs on."
  value       = aws_ecs_cluster.main.cluster
}

output "task_definition_count" {
  description = "The number of instances of the task definition"
  value       = aws_ecs_service.main.desired_count
}

#--------------------
# AWS SECURITY GROUPS
#--------------------
output "security_group_name" {
  description = "The name of the security group"
  value       = aws_security_group.main.name
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.main.id
}

#---------------------------
# APPLICATION LOAD BALANCER
#---------------------------

output "load_balancer_id" {
  description = "The ID of the load balancer (matches arn)."
  value       = aws_lb.main.id
}

output "load_balancer_arn" {
  description = "The ARN of the load balancer (matches id)."
  value       = aws_lb.main.arn
}

output "aws_alb_target_group_name" {
  description = "The name of the application load balancer target group name"
  value       = aws_alb_target_group.main.name
}

output "aws_alb_target_group_id" {
  description = "The name of the application load balancer target group ID"
  value       = aws_alb_target_group.main.id
}
