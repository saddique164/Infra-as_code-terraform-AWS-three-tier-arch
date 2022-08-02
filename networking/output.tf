#---------------networking/output.tf----------------

output "vpc_id" {
  value = aws_vpc.mtc_vpc.id
}

output "db_subnet_group_name" {

  value = aws_db_subnet_group.mtc_rds_securitygroup.*.name

}

output "db_security_group" {

  value = [aws_security_group.mtc_sg["rds"].id]

}

output "public_sg" {

  value = aws_security_group.mtc_sg["public"].id

}

output "mtc_public_subnet_group" {

  value = aws_subnet.mtc_public_subnets.*.id

}