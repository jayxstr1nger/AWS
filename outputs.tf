# outputs.tf

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.golden_vm.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = aws_eip.instance.public_ip
  # OR: aws_instance.golden_vm.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.golden_vm.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.golden_vm.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.instance.id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_subnet.main.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_eip.instance.public_ip}"
}

output "instance_ami" {
  description = "AMI ID used for the instance"
  value       = aws_instance.golden_vm.ami
}

output "iam_role_name" {
  description = "IAM role name attached to the instance"
  value       = aws_iam_role.instance_role.name
}