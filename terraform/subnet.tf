
# Create a public subnet for resources that need direct internet routing.
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.kafka_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "kafka-public-subnet"
    Project = "kafka-one-click-infra"
  }
}

# Create a private subnet for internal resources.
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.kafka_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name    = "kafka-private-subnet"
    Project = "kafka-one-click-infra"
  }
}
