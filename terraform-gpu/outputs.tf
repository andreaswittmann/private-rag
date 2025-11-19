# Output values for RagFlow GPU deployment

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.ragflow_gpu_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.ragflow_gpu_eip.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ragflow_gpu_instance.private_ip
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.ragflow_gpu_sg.id
}

output "key_pair_name" {
  description = "SSH key pair name"
  value       = aws_key_pair.ragflow_gpu_keypair.key_name
}

output "eip_allocation_id" {
  description = "Elastic IP allocation ID"
  value       = aws_eip.ragflow_gpu_eip.id
}

output "instance_arn" {
  description = "EC2 instance ARN"
  value       = aws_instance.ragflow_gpu_instance.arn
}

output "availability_zone" {
  description = "Availability zone of the instance"
  value       = aws_instance.ragflow_gpu_instance.availability_zone
}