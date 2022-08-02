#---------------LoadBalancing / main.tf ------------
resource "aws_lb" "mtc_lb" {
  name               = var.aws_lb_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.mtc_lb_sg]
  subnets            = var.mtc_lb_subnets
  idle_timeout       = 400
  tags = {
    Environment = "mtc_course"
  }
}
resource "aws_lb_target_group" "mtc_tg" {
  name     = "mtc-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port     #80
  protocol = var.tg_protocol #http
  vpc_id   = var.vpc_id

  lifecycle {
    ignore_changes = [name] # This will not let change the target group with
    # new uuid number and structure will remain intact.
    create_before_destroy = true
  }

  health_check {

    healthy_threshold   = var.lb_healthy_threshold   # 2
    unhealthy_threshold = var.lb_unhealthy_threshold # 2
    interval            = var.lb_interval            # 30
    timeout             = var.lb_timeout             # 3

  }
}

resource "aws_lb_listener" "mtc_lb_listener" {
  load_balancer_arn = aws_lb.mtc_lb.arn
  port              = var.listener_port     #80
  protocol          = var.listener_protocol # HTTP

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mtc_tg.arn
  }
}

