# RagFlow EC2 Terraform Configuration

This Terraform configuration deploys RagFlow on an AWS EC2 instance running Ubuntu 24.04 LTS.

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- SSH key pair for EC2 access

## Quick Start

1. **Clone and navigate to the terraform directory:**
   ```bash
   cd terraform
   ```

2. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Edit terraform.tfvars with your values:**
   - Replace `YOUR_IP` with your public IP address
   - Add your SSH public key
   - Adjust instance type and other settings as needed

4. **Initialize Terraform:**
   ```bash
   terraform init
   ```

5. **Plan the deployment:**
   ```bash
   terraform plan
   ```

6. **Apply the configuration:**
   ```bash
   terraform apply
   ```

7. **Get the instance details:**
   ```bash
   terraform output
   ```

## Configuration Options

### Instance Types

- `t3.medium`: Basic deployment (2 vCPU, 4GB RAM) - ~$30/month
- `t3.large`: Better performance (2 vCPU, 8GB RAM) - ~$60/month
- `g4dn.xlarge`: GPU-enabled for advanced features (4 vCPU, 16GB RAM, NVIDIA T4) - ~$200/month

### Security

By default, the security group allows access from anywhere (`0.0.0.0/0`). For production:

1. Replace `allowed_ip` with your specific IP address (e.g., `203.0.113.1/32`)
2. Update `ssh_cidr_blocks` to restrict SSH access
3. Consider adding a VPN or bastion host for additional security

## Accessing RagFlow

After deployment:

1. **SSH into the instance:**
   ```bash
   ssh -i ~/.ssh/ragflow_key ubuntu@<public-ip>
   ```

2. **Access RagFlow web interface:**
   - HTTP: `http://<public-ip>:9380`
   - HTTPS: `https://<public-ip>:9380` (after SSL setup)

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **SSH connection fails:**
   - Verify your SSH key is correctly added to `terraform.tfvars`
   - Check that your IP is allowed in the security group

2. **Instance doesn't start:**
   - Check AWS limits for the selected instance type
   - Verify the AMI is available in your region

3. **RagFlow doesn't load:**
   - Check Docker containers: `docker ps`
   - View logs: `docker logs <container-id>`

### Logs and Monitoring

- Instance system logs: `/var/log/cloud-init-output.log`
- Docker logs: `docker logs $(docker ps -q)`
- Application logs: `/opt/ragflow/logs/`

## Cost Optimization

- Use spot instances for development
- Stop instances when not in use
- Choose appropriate instance types based on workload
- Set up auto-shutdown schedules for non-production environments