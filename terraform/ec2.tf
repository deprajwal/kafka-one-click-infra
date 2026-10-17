
# Find the latest Amazon Linux 2023 AMI published by AWS.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create the EC2 instance that will host Kafka.
resource "aws_instance" "kafka_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.kafka_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.kafka_ec2_profile.name

  associate_public_ip_address = false

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "kafka-one-click-server"
    Project = "kafka-one-click-infra"
  }
}
