# Setup the AWS provider
provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["/home/user/.aws/credentials"] # REPLACE ME
  profile = "customprofile"
}

# Create the 'vpc-jenkins' VPC
resource "aws_vpc" "vpc-jenkins" {
  cidr_block = "10.114.0.0/16"
}

# Setup the '10.114.1.0/24' subnet in the 'vpc-jenkins' VPC
resource "aws_subnet" "jenkins-subnet" {
  vpc_id                  = aws_vpc.vpc-jenkins.id
  cidr_block              = "10.114.1.0/24"
}

# Create the 'igw-jenkins' internet gateway in the 'vpc-jenkins' VPC
resource "aws_internet_gateway" "igw-jenkins" {
  vpc_id = aws_vpc.vpc-jenkins.id
}

# Create the 'route-table-jenkins' route table to send traffic
# destined for 0.0.0.0/0 to the 'igw-jenkins' Internet Gateway
resource "aws_route_table" "route-table-jenkins" {
  vpc_id = aws_vpc.vpc-jenkins.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-jenkins.id
  }
}

# Create the route-jenkins route for the Internet Gateway to allow Internet access
resource "aws_route" "route-jenkins" {
  route_table_id = aws_route_table.route-table-jenkins.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw-jenkins.id
}

# Associate the 'route-table-jenkins' route table with the 'jenkins-subnet' subnet
resource "aws_route_table_association" "route-table-association-jenkins" {
  subnet_id      = aws_subnet.jenkins-subnet.id
  route_table_id = aws_route_table.route-table-jenkins.id
}

# Create the 'security-group-jenkins' security group
# and allow inbound traffic destined for port 22
resource "aws_security_group" "security-group-jenkins" {
  name        = "security-group-jenkins"
  description = "Allow SSH access"

  vpc_id = aws_vpc.vpc-jenkins.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the 'jenkins-app-test' EC2 instance with the preceeding resources
# and create the '/home/ec2-user/hello.txt' file with the contents "Hello, World!"
resource "aws_instance" "jenkins-app-test" {
  ami           = "ami-xxxxxxxxxxxxxxxxx" # REPLACE ME
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.jenkins-subnet.id
  key_name      = "your_keypair" # REPLACE ME
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.security-group-jenkins.id]

  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World!" >> /home/ec2-user/hello.txt
  EOF
}
