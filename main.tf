provider "aws" {
  region = "eu-central-2"  # Specify the AWS region you want to use
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}



# Create two subnets
resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-2a"

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-2b"

  tags = {
    Name = "private_subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

# Create a route table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "main_route_table"
  }
}

# Associate the route table with the subnets
resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.rtb.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.rtb.id
}

# Create a security group to allow SSH and HTTP
resource "aws_security_group" "allow_ssh_http" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "allow_ssh_http"
  }
}

/*

# Create an EC2 instance in the first subnet
resource "aws_instance" "web-frontend" {
  ami           = "ami-08076a271deb06518"  # Win16
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet_2.id
  security_groups = [aws_security_group.allow_ssh_http.id]
 user_data = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  echo '<center><h1> Dies ist Niels Webserver! </h1></center>' > /var/www/html/index.html
EOF

  tags = {
    Name = "web_server"
  }
}

*/