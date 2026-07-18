# golden-image-vm.tf - EC2 instance from golden AMI

# Data source to fetch the golden AMI (if you want to search by name instead of ID)
data "aws_ami" "golden" {
  most_recent = true
  owners      = ["self"]  # Or AWS account ID

  filter {
    name   = "name"
    values = ["golden-image-*"]  # Pattern to match your golden image name
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  # Optional: Filter by tags
  tags = {
    Purpose = "golden-image"
    Version = "latest"
  }
}

# Alternative: Use specific AMI ID directly
# locals {
#   ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.golden.id
# }

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.instance_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.instance_name}-igw"
  }
}

# Subnet
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.instance_name}-subnet"
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.instance_name}-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Security Group
resource "aws_security_group" "instance" {
  name        = "${var.instance_name}-sg"
  description = "Security group for golden image VM"
  vpc_id      = aws_vpc.main.id

  # SSH access (Linux)
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RDP access (Windows)
  ingress {
    description = "RDP from anywhere"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access (optional)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access (optional)
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Custom application port (example)
  ingress {
    description = "Custom app port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Key Pair (if creating new)
resource "aws_key_pair" "instance" {
  count      = var.ssh_public_key != "" ? 1 : 0
  key_name   = var.key_name
  public_key = var.ssh_public_key

  tags = {
    Name = var.key_name
  }
}

# IAM Instance Profile (optional - for SSM, S3 access, etc.)
resource "aws_iam_role" "instance_role" {
  name = "${var.instance_name}-role"

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
    Name = "${var.instance_name}-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.instance_name}-profile"
  role = aws_iam_role.instance_role.name
}

# Main EC2 Instance from Golden AMI
resource "aws_instance" "golden_vm" {
  # Use specific AMI ID or the latest golden image
  ami = var.ami_id != "" ? var.ami_id : data.aws_ami.golden.id
  
  instance_type = var.instance_type
  key_name      = var.ssh_public_key != "" ? aws_key_pair.instance[0].key_name : var.key_name
  
  # Networking
  subnet_id                   = aws_subnet.main.id
  vpc_security_group_ids      = [aws_security_group.instance.id]
  associate_public_ip_address = true
  
  # IAM Role
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  
  # Root volume configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
    
    tags = {
      Name = "${var.instance_name}-root-volume"
    }
  }
  
  # Additional EBS volumes (optional)
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
    
    tags = {
      Name = "${var.instance_name}-data-volume"
    }
  }
  
  # User data script (for bootstrapping)
  user_data = <<-EOF
    #!/bin/bash
    echo "Starting golden image VM initialization..."
    
    # Update system packages
    sudo yum update -y || sudo apt-get update -y
    
    # Install additional software
    sudo yum install -y git docker || sudo apt-get install -y git docker.io
    
    # Start services
    sudo systemctl start docker || sudo service docker start
    sudo systemctl enable docker || sudo update-rc.d docker enable
    
    # Set hostname
    sudo hostnamectl set-hostname ${var.instance_name}
    
    echo "Initialization completed!"
  EOF
  
  # Enable detailed monitoring
  monitoring = var.enable_monitoring
  
  # Tags
  tags = {
    Name        = var.instance_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
    Purpose     = "Golden-Image-VM"
    CreatedBy   = "Terraform"
  }
  
  # Volume tags
  volume_tags = {
    Name        = "${var.instance_name}-volumes"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  
  # Lifecycle rules
  lifecycle {
    ignore_changes = [
      ami,  # Prevent recreation when AMI changes
      user_data,
    ]
    create_before_destroy = true
  }
}

# Elastic IP (optional - for static IP)
resource "aws_eip" "instance" {
  instance = aws_instance.golden_vm.id
  domain   = "vpc"
  
  tags = {
    Name = "${var.instance_name}-eip"
  }
}

# CloudWatch Alarms (optional monitoring)
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.instance_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU utilization is too high"
  alarm_actions       = []  # Add SNS topic ARN here
  
  dimensions = {
    InstanceId = aws_instance.golden_vm.id
  }
}

# SSM Parameter Store - Store instance details (optional)
resource "aws_ssm_parameter" "instance_details" {
  name  = "/${var.project_name}/${var.environment}/instance-id"
  type  = "String"
  value = aws_instance.golden_vm.id
  
  tags = {
    Environment = var.environment
  }
}