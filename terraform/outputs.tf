output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ragflow_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.ragflow_eip.public_ip
}

output "instance_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.ragflow_instance.public_dns
}

output "ssh_connection_command" {
  description = "Command to connect to the instance using SSH"
  value       = "ssh -i ~/.ssh/ragflow_key ubuntu@${aws_eip.ragflow_eip.public_ip}"
}

output "vscode_remote_connection" {
  description = "Instructions for VS Code Remote SSH connection"
  value       = "Add to ~/.ssh/config: Host ragflow-aws\n  HostName ${aws_eip.ragflow_eip.public_ip}\n  User ubuntu\n  IdentityFile ~/.ssh/ragflow_key"
}

output "ragflow_url" {
  description = "URL to access RagFlow"
  value       = "http://${aws_eip.ragflow_eip.public_ip}:9380"
}

output "ragflow_https_url" {
  description = "HTTPS URL to access RagFlow"
  value       = "https://${aws_eip.ragflow_eip.public_ip}:9380"
}