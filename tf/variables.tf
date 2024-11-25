variable "region" {
  description = "AWS Region."
  type        = string
  default     = "eu-north-1"
}

variable "domain" {
  description = "Domain of an application."
  type        = string
  default     = "gms"
}

variable "environment" {
  description = "Short environment name."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Invalid var.environment value. Allowed: dev, qa, prod."
  }
}

variable "role" {
  description = "Application Role."
  type        = string
  default     = "task"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for Private subnets."
  type        = list(string)
  default = [
    "10.10.0.0/24",
    "10.10.1.0/24",
    "10.10.2.0/24",
  ]
  validation {
    condition     = length(var.private_subnet_cidrs) == length(toset(var.private_subnet_cidrs))
    error_message = "The var.private_subnet_cidrs can not contain same CIDR blocks."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for Public subnet."
  type        = list(string)
  default = [
    "10.10.100.0/24",
    "10.10.101.0/24",
    "10.10.102.0/24",
  ]
  validation {
    condition     = length(var.public_subnet_cidrs) == length(toset(var.public_subnet_cidrs))
    error_message = "The var.public_subnet_cidrs can not contain same CIDR blocks."
  }
}

variable "instance_type" {
  description = "EC2 instance type. Check https://aws.amazon.com/ec2/instance-types/. Kubernetes cluster requires at least 4 GiB of RAM."
  type        = string
  default     = "t3.large"
}

variable "db" {
  description = "RDS database configuration."
  sensitive   = true
  type = object({
    create = optional(bool, "true")

    engine  = optional(string, "postgres")
    version = optional(string, "15.10")

    name     = optional(string, "core")
    username = optional(string, "postgres")
    password = optional(string, "postgres")
    port     = optional(number, 5432)
  })
  default = {}
}
