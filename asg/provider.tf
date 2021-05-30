terraform {
  required_version = ">= 0.15"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.39"
    }

    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
  }
}
