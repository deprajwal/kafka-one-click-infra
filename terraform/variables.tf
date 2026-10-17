
# AWS region where the Kafka infrastructure will be created.
variable "aws_region" {
  description = "AWS region for the Kafka One-Click Infrastructure"
  type        = string
  default     = "ap-south-1"
}

# IPv4 CIDR range assigned to the VPC.
variable "vpc_cidr" {
  description = "IPv4 CIDR block for the Kafka VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# EC2 instance type used for the Kafka server.
variable "instance_type" {
  description = "EC2 instance type for the Kafka server"
  type        = string
  default     = "t3.large"
}
