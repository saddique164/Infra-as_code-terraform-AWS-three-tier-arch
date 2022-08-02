# ----- Network/main.tf ------

data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 100
}


resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets

}

resource "aws_vpc" "mtc_vpc" {

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {
    Name = "mtc_vpc.${random_integer.random.id}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "mtc_public_subnets" {

  # count                 = length(var.public_cidrs)
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  # availability_zone       = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"][count.index]
  # availability_zone       = data.aws_availability_zones.available.names[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "mtc_public_.${count.index + 1}"
  }
}

resource "aws_route_table_association" "mtc_public_assot" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.mtc_public_subnets.*.id[count.index]
  route_table_id = aws_route_table.mtc_public_rt.id
}


resource "aws_subnet" "mtc_private_subnets" {

  # count                   = length(var.private_cidrs)
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  # availability_zone       = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"][count.index]
  # availability_zone       = data.aws_availability_zones.available.names[count.index]
  availability_zone = random_shuffle.az_list.result[count.index]


  tags = {
    Name = "mtc_private_.${count.index + 1}"
  }
}

resource "aws_internet_gateway" "mtc_internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "mtc_igw"
  }
}

resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id

  tags = {
    Name = "mtc_public"
  }

}


resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id
}

# ------It will be used all subnets which are not using pubic roite table. We are using VPC default route-----------
resource "aws_default_route_table" "mtc_private_rt" {

  default_route_table_id = aws_vpc.mtc_vpc.default_route_table_id

  tags = {
    Name = "mtc_private"
  }

}

resource "aws_security_group" "mtc_sg" {
  # name        = "pubic_sg"
  # description = "Security Group for Public Access"
  for_each    = var.security_groups
  name        = each.value.name # vaue is public in locals file
  description = each.value.description
  vpc_id      = aws_vpc.mtc_vpc.id

  # ingress {
  dynamic "ingress" {
    for_each = each.value.ingress # here the value is public in local file
    # from_port   = 22
    # to_port     = 22
    # protocol    = "tcp"
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_db_subnet_group" "mtc_rds_securitygroup" {
  count      = var.db_subnet_group == true ? 1 : 0 #if db_subnet_group is true create 1 subnet otherwise 0 
  name       = "mtc_rds_securitygroup"
  subnet_ids = aws_subnet.mtc_private_subnets.*.id

  tags = {
    Name = "mtc_rds_sng"
  }
}