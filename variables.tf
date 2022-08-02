#-------root / variable.tf -----------------

variable "aws_region" {
  default = "us-west-2"
}

variable "access_ip" {
  type = string
}

# -------------database variables -----------
variable "dbname" {
  type = string
}
variable "dbusername" {
  type      = string
  sensitive = true
}
variable "dbpassword" {
  type      = string
  sensitive = true
}

# ------------LoadBalancing variable ----------

variable "lbname" {
  type = string
}

variable "lb_type" {
  type = string
}

#--------------target group variables-----

variable "port" {
  type = number
}

variable "protocol" {
  type = string
}

variable "healthy_threshold" {
  type = number
}

variable "unhealthy_threshold" {
  type = number
}

variable "interval" {
  type = number
}

variable "timeout" {
  type = number
}