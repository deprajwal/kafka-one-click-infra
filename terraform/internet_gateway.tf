
# Create an Internet Gateway for the Kafka VPC.
resource "aws_internet_gateway" "kafka_igw" {
  vpc_id = aws_vpc.kafka_vpc.id

  tags = {
    Name    = "kafka-one-click-igw"
    Project = "kafka-one-click-infra"
  }
}
