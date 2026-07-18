# provider.tf - AWS Provider Configuration

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Use the latest 5.x version
    }
  }
}

# Optional: Tags to apply to all resources
# Primary AWS Provider Configuration
provider "aws" {
  # Authentication Methods (choose one):
  
  # Option 1: Environment Variables (recommended for CI/CD)
  # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN (optional)
  # No need to specify anything here if using environment variables
  
  # Option 2: Static Credentials (not recommended for production)
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  
  # Option 3: Profile from ~/.aws/credentials
  # profile = "default"
  
  # Region Configuration
  region = var.aws_region
  
 default_tags {
  tags = {
     Environment = var.environment
     ManagedBy   = "Terraform"
     Project     = var.project_name
   }
} 
  # Optional: Custom endpoint (for localstack or custom AWS endpoints)
  # endpoints {
  #   ec2 = "http://localhost:4566"
  #   s3  = "http://localhost:4566"
  # }
  
  # Optional: Assume Role Configuration
  # assume_role {
  #   role_arn     = "arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME"
  #   session_name = "terraform-session"
  #   external_id  = "EXTERNAL_ID"
  # }
} 
