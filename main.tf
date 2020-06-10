provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "aws_demo" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_classiclink_dns_support = true
  assign_generated_ipv6_cidr_block = false
  tags = {
      Name = "csyee6225"
      Tag2 = "new tag"
  }
}

# Create a Subnet
resource "aws_subnet" "subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = "${aws_vpc.aws_demo.id}"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "csyee6225-subnet"
  }
}

resource "aws_subnet" "subnet1" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = "${aws_vpc.aws_demo.id}"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "csyee6225-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  cidr_block = "10.0.3.0/24"
  vpc_id     = "${aws_vpc.aws_demo.id}"
  availability_zone = "us-east-1c"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "csyee6225-subnet2"
  }
}

# Create a internt gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.aws_demo.id}"

  tags = {
    Name = "csyee6225-gateway"
  }
}

#Create a route table
resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.aws_demo.id}"

  # route {
  #   cidr_block = "${aws_subnet.subnet.cidr_block}"
  #   gateway_id = "${aws_internet_gateway.gateway.id}"
  # }

  # route {
  #   cidr_block = "${aws_subnet.subnet1.cidr_block}"
  #   gateway_id = "${aws_internet_gateway.gateway.id}"
  # }

  # route {
  #   cidr_block = "${aws_subnet.subnet2.cidr_block}"
  #   gateway_id = "${aws_internet_gateway.gateway.id}"
  # }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }


  tags = {
    Name = "csyee6225-route"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.r.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.r.id
}

resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.r.id
}