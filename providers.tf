terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.36"    # This "~>" sign will help to upgrade the version from 3.36 to the latest version like 3.75 
                             # but if you user 3.36.0, it will update to 3.36.latest version.
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}
