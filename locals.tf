locals {
  vpc_cidr = "10.123.0.0/16"
}

locals {
  security_groups = {
    public = {
      name        = "pubic_sg"
      description = "Security Group for Public Access"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "tcp"
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
        nginx = {
          from     = 8000
          to       = 8000
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
    rds = {
      name        = "reds_sg"
      description = "Security Group for private RDS Access"
      ingress = {
        mysql = {
          from        = 3306
          to          = 3306
          protocol    = "tcp"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}