
# Create a security group for the Kafka EC2 instance.
resource "aws_security_group" "kafka_sg" {
  name        = "kafka-one-click-sg"
  description = "Security group for Kafka infrastructure"
  vpc_id      = aws_vpc.kafka_vpc.id

  # Allow Kafka traffic from within the VPC.
  ingress {
    description = "Kafka access from within the VPC"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow outbound connections for updates and downloads.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "kafka-one-click-sg"
    Project = "kafka-one-click-infra"
  }
}
