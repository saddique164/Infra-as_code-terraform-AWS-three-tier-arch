#-----------------compute/output -----------

output "instance" { # for referecing to the root/output file

  value     = aws_instance.mtc_node[*] # output everything
  sensitive = true
}

output "instance_port" {
  value = aws_lb_target_group_attachment.mtc_target_attach[0].port
}