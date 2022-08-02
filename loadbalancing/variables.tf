variable "mtc_lb_subnets" {}

variable "mtc_lb_sg" {}

variable "load_balancer_type" {
  type = string
}

variable "aws_lb_name" {
  type = string
}

variable "tg_port" {}
variable "tg_protocol" {}
variable "lb_healthy_threshold" {}   # 2
variable "lb_unhealthy_threshold" {} # 2
variable "lb_interval" {}            # 30
variable "lb_timeout" {}             # 3
variable "vpc_id" {}
variable "listener_port" {}
variable "listener_protocol" {}