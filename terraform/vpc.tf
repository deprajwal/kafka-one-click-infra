
# Create the main VPC for the Kafka One-Click Infra.
resource "aws_vpc" "kafka_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "kafka-one-click-vpc"
    Project = "kafka-one-click-infra"
  }
}
