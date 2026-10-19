
# Public subnet in Availability Zone A
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.kafka_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "kafka-public-subnet"
    Project = "kafka-one-click-infra"
    Tier    = "Public"
  }
}

# Private subnet in Availability Zone A
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.kafka_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = {
    Name    = "kafka-private-subnet"
    Project = "kafka-one-click-infra"
    Tier    = "Private"
  }
}

# Public subnet in Availability Zone B for ALB
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.kafka_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "kafka-public-subnet-2"
    Project = "kafka-one-click-infra"
    Tier    = "Public"
  }
}

# Private subnet in Availability Zone B for application instances
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.kafka_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = {
    Name    = "kafka-private-subnet-2"
    Project = "kafka-one-click-infra"
    Tier    = "Private"
  }
}
