  # Optional: Tags to apply to all resources
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }
  
  # Optional: S3 backend configuration (should be in backend.tf, not here)
  # backend "s3" {
  #   bucket         = "terraform-state-bucket"
  #   key            = "project/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }

# variables.tf content - add these to a separate variables.tf file
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "my-project"
}

# Optional: Aliased providers for multiple regions
provider "aws" {
  alias  = "secondary_region"
  region = "us-west-2"
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
      Region      = "us-west-2"
    }
  }
}

# Optional: Provider for specific AWS partition (GovCloud, China)
# provider "aws" {
#   alias   = "govcloud"
#   region  = "us-gov-east-1"
#   profile = "govcloud"
# }

# Optional: Data source to get current AWS account and region info
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Outputs for debugging
output "current_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "current_region" {
  value = data.aws_region.current.name
}

output "current_user_arn" {
  value = data.aws_caller_identity.current.arn
}