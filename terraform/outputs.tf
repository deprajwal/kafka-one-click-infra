
# VPC ID
output "vpc_id" {
  description = "ID of the Kafka VPC"
  value       = aws_vpc.kafka_vpc.id
}

# Public subnet IDs
output "public_subnet_id" {
  description = "ID of the public subnet in AZ A"
  value       = aws_subnet.public_subnet.id
}

output "public_subnet_2_id" {
  description = "ID of the public subnet in AZ B"
  value       = aws_subnet.public_subnet_2.id
}

# Private subnet IDs
output "private_subnet_id" {
  description = "ID of the private subnet in AZ A"
  value       = aws_subnet.private_subnet.id
}

output "private_subnet_2_id" {
  description = "ID of the private subnet in AZ B"
  value       = aws_subnet.private_subnet_2.id
}

# Kafka EC2 details
output "kafka_instance_id" {
  description = "EC2 instance ID used by Ansible SSM"
  value       = aws_instance.kafka_server.id
}

output "kafka_private_ip" {
  description = "Private IP address of the Kafka server"
  value       = aws_instance.kafka_server.private_ip
}

# SSM transfer bucket
output "ssm_transfer_bucket" {
  description = "S3 bucket used by the Ansible SSM connection"
  value       = aws_s3_bucket.ssm_transfer.bucket
}
