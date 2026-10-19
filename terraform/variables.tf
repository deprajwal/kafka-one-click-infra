
# AWS region
variable "aws_region" {
  description = "AWS region for Kafka One-Click Infrastructure"
  type        = string
  default     = "ap-south-1"
}

# VPC network
variable "vpc_cidr" {
  description = "IPv4 CIDR block for the Kafka VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Kafka EC2 instance
variable "instance_type" {
  description = "EC2 instance type for Kafka"
  type        = string
  default     = "t3.large"
}

# Application EC2 instances
variable "app_instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t3.micro"
}

# Application configuration
variable "app_port" {
  description = "Port used by the application"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Application health check path"
  type        = string
  default     = "/health"
}

# Auto Scaling Group capacity
variable "asg_min_size" {
  description = "Minimum application instances"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired application instances"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum application instances"
  type        = number
  default     = 4
}

# Application CPU scaling target
variable "app_cpu_target" {
  description = "Target average CPU utilization percentage"
  type        = number
  default     = 60
}
