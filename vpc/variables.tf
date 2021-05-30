variable "environment" {
  type = string
  description = "Environment name"
}
variable "region" { 
  type = string 
  description = "Region in which vpc will be created"
  }
variable "vpc_cidr" {
  type = string
  description = "VPC CIDR block"
}
variable "azs" {
  type    = list
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
  description = "Availability zones in which we create our subnets"
}

variable "subnet_size" {
  type    = string
  default = "24"
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "tags" {
  type        = map
  default     = {}
  description = "Map of tags for created resourses"
}

variable "create_s3_vpce" {
  description = "Controls if VPCE should be created (it attatched to the the rout tables)"
  type        = bool
  default     = false
}
