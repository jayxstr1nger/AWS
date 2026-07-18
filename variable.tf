# variables.tf - Additional variables for VM creation

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "Golden AMI ID (base image)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Example - replace with your golden AMI
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "my-key-pair"
}

variable "instance_name" {
  description = "Name tag for the instance"
  type        = string
  default     = "golden-image-vm"
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  sensitive   = true
  default     = ""
}

# Optional: For Windows instances
variable "windows_admin_password" {
  description = "Windows administrator password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}