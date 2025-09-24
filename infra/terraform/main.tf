terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "key_name" {
  type    = string
  default = ""
  description = "Optional: existing AWS key pair name to access EC2 via SSH (leave empty for none)"
}

# ECR repository to store docker images (exemplo)
resource "aws_ecr_repository" "app" {
  name                 = "ecr-app-repo"
  image_tag_mutability = "MUTABLE"
}

# Security group for the app server
resource "aws_security_group" "app_sg" {
  name        = "c4model-app-sg"
  description = "Allow HTTP and SSH (optional)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH (optional)"
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

  tags = {
    Name = "c4model-app-sg"
  }
}

data "aws_vpc" "default" {
  default = true
}

# Latest Amazon Linux 2 AMI (x86_64)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.app_sg.name]

  key_name = var.key_name != "" ? var.key_name : null

  # user_data: basic setup to install docker and run a container (placeholder)
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y || yum install -y docker
    service docker start
    usermod -a -G docker ec2-user
    # (opcional) - aqui você poderia dar pull da imagem do ECR e rodar
    # docker run -d -p 80:80 --name c4model-app ${aws_ecr_repository.app.repository_url}:latest
  EOF

  tags = {
    Name = "c4model-app-instance"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ec2_public_ip" {
  value = aws_instance.app.public_ip
}
