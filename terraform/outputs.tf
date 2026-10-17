
output "vpc_id" {
  description = "ID of the Kafka VPC"
  value       = aws_vpc.kafka_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}

output "kafka_instance_id" {
  description = "EC2 instance ID used by Ansible SSM"
  value       = aws_instance.kafka_server.id
}

output "kafka_private_ip" {
  description = "Private IP advertised by Kafka"
  value       = aws_instance.kafka_server.private_ip
}

output "ssm_transfer_bucket" {
  description = "S3 bucket used by the Ansible SSM connection"
  value       = aws_s3_bucket.ssm_transfer.bucket
}
