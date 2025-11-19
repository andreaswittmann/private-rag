provider "aws" {
  region = var.aws_region
}

# Use the specific Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 24.04)
data "aws_ami" "ubuntu_gpu" {
  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-0323015fcbee6f991"]
  }
}

# Security Group
resource "aws_security_group" "ragflow_gpu_sg" {
  name        = "RagFlowGPUSecurityGroup"
  description = "Security group for RagFlow GPU deployment"

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

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "SSH access"
  }

  # Ollama API
  ingress {
    from_port   = 11434
    to_port     = 11434
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "Ollama API access"
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
    Name        = "RagFlowGPUSecurityGroup"
    Environment = var.environment
    project     = var.project
  }
}

# Update security group to allow SSH
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_cidr_blocks
  security_group_id = aws_security_group.ragflow_gpu_sg.id
  description       = "Allow SSH access"
}

# IAM Role for EC2 Instance
resource "aws_iam_role" "ragflow_gpu_role" {
  name = "RagFlowGPURole"

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
    Name        = "RagFlowGPURole"
    Environment = var.environment
    project     = var.project
  }
}

# Create instance profile
resource "aws_iam_instance_profile" "ragflow_gpu_profile" {
  name = "RagFlowGPUProfile"
  role = aws_iam_role.ragflow_gpu_role.name

  tags = {
    Name        = "RagFlowGPUProfile"
    Environment = var.environment
    project     = var.project
  }
}

# Create an AWS key pair from the provided public key
resource "aws_key_pair" "ragflow_gpu_keypair" {
  key_name   = "ragflow-gpu-keypair"
  public_key = var.ssh_public_key
}

# EC2 Instance
resource "aws_instance" "ragflow_gpu_instance" {
  ami                    = data.aws_ami.ubuntu_gpu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ragflow_gpu_keypair.key_name
  iam_instance_profile   = aws_iam_instance_profile.ragflow_gpu_profile.name
  vpc_security_group_ids = [aws_security_group.ragflow_gpu_sg.id]
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
resource "aws_eip" "ragflow_gpu_eip" {
  domain = "vpc"
  tags = {
    Name        = "RagFlowGPUEIP"
    Environment = var.environment
    project     = var.project
  }
}

# Associate EIP with EC2 instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.ragflow_gpu_instance.id
  allocation_id = aws_eip.ragflow_gpu_eip.id
}