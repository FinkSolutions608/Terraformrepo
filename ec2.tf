


# Create an EC2 instance in the first subnet
resource "aws_instance" "web-frontend" {
  ami                         = "ami-0501f3dfc19235d5f" # AmazonLinux2
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.subnet_1.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_ssh_http.id]
  user_data                   = <<-EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install -y httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd
  sudo echo '<center><h1> Dies ist Niels Webserver! </h1></center>' > /var/www/html/index.html

EOF

  tags = {
    Name = "web_server"
  }
}

