variable "region" {
  type = string
  description = "Enter Region:"
}
variable "a_key" {
  type        = string
  description = "Enter Access Key:"
}
variable "s_key" {
  type        = string
  description = "Enter Secret Key:"
}
variable "key_name" {
  type        = string
  description = "Enter SSH Key Name:"

}

variable "db_user" {
  type        = string
  description = "Enter DB User:"
}

variable "db_name" {
  type        = string
  description = "Enter DB Name:"
}

variable "db_pass" {
  type        = string
  description = "Enter DB Password:"
}

variable "ami" {
  type        = string
  description = "Enter AMI ID:"
}

variable "bucket" {
  type        = string
  description = "Enter Bucket Name:"
}

provider "aws" {
  region = var.region
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
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "csyee6225-subnet"
  }
}

resource "aws_subnet" "subnet1" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = "${aws_vpc.aws_demo.id}"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "csyee6225-subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  cidr_block = "10.0.3.0/24"
  vpc_id     = "${aws_vpc.aws_demo.id}"
  availability_zone = "${var.region}c"
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


resource "aws_security_group" "my_sg" {
  name        = "Demo SG"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.aws_demo.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WebApp"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Application"
  }
}

resource "aws_security_group" "mydb_sg" {
  name        = "allow_db"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.aws_demo.id

  ingress {
    description     = "DB Connection"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.my_sg.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database"
  }
}

resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 30
}

resource "aws_s3_bucket" "b" {
  bucket        = var.bucket
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  lifecycle_rule {
    prefix  = "config/"
    enabled = true

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

  }
  tags = {
    Name        = "My_bucket"
    Environment = "Dev"
  }
}
resource "aws_db_subnet_group" "db_group" {
  name       = "db_group"
  subnet_ids = [aws_subnet.subnet1.id,aws_subnet.subnet2.id]

  tags = {
    Name = "My_DB_subnet_group"
  }
}

resource "aws_dynamodb_table" "dbTable" {
  name = "csye6225"
  hash_key = "id"
  billing_mode = "PROVISIONED"
  write_capacity = 5
  read_capacity = 5
  attribute {
    name = "id"
    type = "S"
  }

}

resource "aws_db_instance" "default" {
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "11"
  instance_class    = "db.t3.micro"
  name              = var.db_name
  username          = var.db_user
  password          = var.db_pass
  identifier        = "csye6225-su2020"
  db_subnet_group_name = "db_group"
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.mydb_sg.id]
}





resource "aws_iam_role" "EC2_Role" {
  name = "EC2-CSYE6225"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    name = "EC2-CSYE6225"
  }
}

resource "aws_iam_policy" "mypolicy" {
  name   = "WebAppS3"
  # role   = aws_iam_role.EC2Role.id
  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [{
		"Effect": "Allow",
		"Action": "s3:*",
		"Resource": [
			"arn:aws:s3:::web.abhi.thakkar",
			"arn:aws:s3:::web.abhi.thakkar/*"
		]
	}]
}
  EOF

}

resource "aws_iam_role_policy_attachment" "attach-policy" {
  role       = "${aws_iam_role.EC2_Role.name}"
  policy_arn = "${aws_iam_policy.mypolicy.arn}"
}

resource "aws_iam_instance_profile" "EC2Profile" {
  name = "EC2-CSYE6225"
  role = "${aws_iam_role.EC2_Role.name}"
}

resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet2.id
  iam_instance_profile   = "EC2-CSYE6225"
  key_name = "awsEc2_ssh_key"
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
  # user_data = file("install.sh")
  tags = {
    Name = " Instance"
  }
}

data "template_file" "data" {
  template = "${file("install.tpl")}"

  vars={
    endpoint = "${aws_db_instance.default.endpoint}"
    a_key= var.a_key
    s_key= var.s_key
  }
}

