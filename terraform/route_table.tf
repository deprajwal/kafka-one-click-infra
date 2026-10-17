
# Route table for internet-bound traffic from the public subnet.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.kafka_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kafka_igw.id
  }

  tags = {
    Name = "kafka-public-route-table"
  }
}

# Route table for traffic from the private subnet.
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.kafka_vpc.id

  tags = {
    Name = "kafka-private-route-table"
  }
}

# Associate the public subnet with its route table.
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate the private subnet with its route table.
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}
