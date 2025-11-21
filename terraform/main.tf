provider "aws" {
  region = var.aws_region
}

# Get the latest Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu_24_04" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "ragflow_sg" {
  name        = "RagFlowSecurityGroup"
  description = "Security group for RagFlow deployment"

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "HTTP access"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "HTTPS access"
  }

  # RagFlow
  ingress {
    from_port   = 9380
    to_port     = 9380
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "RagFlow web interface"
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "SSH access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "RagFlowSecurityGroup"
    Environment = var.environment
    project     = var.project
  }
}


# IAM Role for EC2 Instance
resource "aws_iam_role" "ragflow_role" {
  name = "RagFlowInstanceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "RagFlowInstanceRole"
    Environment = var.environment
    project     = var.project
  }
}

# Create instance profile
resource "aws_iam_instance_profile" "ragflow_profile" {
  name = "RagFlowInstanceProfile"
  role = aws_iam_role.ragflow_role.name

  tags = {
    Name        = "RagFlowInstanceProfile"
    Environment = var.environment
    project     = var.project
  }
}

# Create an AWS key pair from the provided public key
resource "aws_key_pair" "ragflow_keypair" {
  key_name   = "ragflow-keypair"
  public_key = var.ssh_public_key
}

# EC2 Instance
resource "aws_instance" "ragflow_instance" {
  ami                    = "ami-004e960cde33f9146"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ragflow_keypair.key_name
  iam_instance_profile   = aws_iam_instance_profile.ragflow_profile.name
  vpc_security_group_ids = [aws_security_group.ragflow_sg.id]
  user_data              = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name        = var.ec2_name
    Environment = var.environment
    project     = var.project
  }
}

# Elastic IP
resource "aws_eip" "ragflow_eip" {
  domain = "vpc"
  tags = {
    Name        = "RagFlowEIP"
    Environment = var.environment
    project     = var.project
  }
}

# Associate EIP with EC2 instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ragflow_instance.id
  allocation_id = aws_eip.ragflow_eip.id
}