resource "aws_lb" "myalb" {
  name               = "myALB"
  internal           = false
  security_groups    = [aws_security_group.web_server_lb.id, aws_security_group.internal.id]
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
}


resource "aws_lb_target_group" "frontend" {
  name        = "frontend-tg"
  target_type = "instance"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "3000"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "frontendTargetGroup"
  }
}


resource "aws_lb_target_group" "backend" {
  name        = "backend-tg"
  target_type = "instance"
  port        = 3010
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "3000"
    matcher             = "200"
    interval            = 15
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "backendTargetGroup"
  }
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}


resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    path_pattern {
      values = ["/", "/*.html"]
    }
  }
}


resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}


output "elb_dns_name" {
  value       = aws_lb.myalb.dns_name
  description = "The domain name of the load balancer"
}
