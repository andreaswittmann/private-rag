# RagFlow GPU Terraform Configuration

This directory contains Terraform configuration files for deploying RagFlow on AWS with GPU acceleration.

## Overview

This Terraform configuration creates:
- GPU-enabled EC2 instance (g4dn.xlarge by default) with Ubuntu 24.04
- Pre-installed NVIDIA drivers and CUDA toolkit via Deep Learning AMI
- Security groups with appropriate ports for RagFlow and GPU workloads
- IAM roles and instance profiles
- Elastic IP for consistent public access
- SSH key pair for secure access (ubuntu user)

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0.0
- SSH key pair for instance access

## Quick Start

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars with your values:**
   - Set your SSH public key
   - Adjust instance type if needed
   - Configure IP restrictions for security

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

## Configuration Options

### Instance Types

Recommended GPU instance types for RagFlow:

| Instance Type | GPU | VRAM | vCPUs | RAM | Cost/Hour |
|---------------|-----|------|-------|-----|-----------|
| g4dn.xlarge  | T4  | 16GB | 4     | 16GB| ~$0.71   |
| g4dn.2xlarge | T4  | 16GB | 8     | 32GB| ~$1.05   |
| g5.xlarge    | A10G| 24GB | 4     | 16GB| ~$1.21   |
| g6e.xlarge   | L40S| 48GB | 4     | 32GB| ~$1.22   |

### Security Considerations

- The default configuration allows SSH from anywhere (`0.0.0.0/0`)
- For production, restrict `allowed_ip` and `ssh_cidr_blocks` to your IP ranges
- Consider using AWS Systems Manager Session Manager for SSH access

## Outputs

After deployment, Terraform will output:
- Instance ID and public/private IPs
- Security group ID
- SSH key pair name
- Elastic IP allocation ID

## GPU Setup

The Deep Learning AMI comes pre-configured with NVIDIA drivers and CUDA. After Terraform deployment, you'll need to:
1. SSH into the instance (use ubuntu user)
2. Verify GPU functionality with nvidia-smi
3. Configure Docker for GPU support
4. Deploy RagFlow with GPU acceleration

## Cleanup

To destroy all resources:
```bash
terraform destroy -var-file=terraform.tfvars
```

## Cost Optimization

- GPU instances are expensive - stop instances when not in use
- Use spot instances for development/testing
- Consider reserved instances for production workloads

## Troubleshooting

- **Instance won't start**: Check AWS service limits for GPU instances
- **SSH connection fails**: Verify security group rules and key pair
- **GPU not detected**: Ensure correct AMI and instance type

## Files

- `main.tf`: Main infrastructure configuration
- `variables.tf`: Input variable definitions
- `outputs.tf`: Output value definitions
- `user_data.sh`: EC2 instance initialization script
- `terraform.tfvars.example`: Example variables file