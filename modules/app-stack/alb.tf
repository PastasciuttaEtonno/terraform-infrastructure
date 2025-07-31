# =============================================================================
# APPLICATION LOAD BALANCER (ALB)
# =============================================================================
resource "aws_lb" "main_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
  tags = {
    Name      = var.alb_name
    ManagedBy = "Terraform"
  }
}

# =============================================================================
# SECURITY GROUP PER L'ALB
# =============================================================================
resource "aws_security_group" "alb_sg" {
  name        = "${var.alb_name}-sg"
  description = "Security Group for the Application Load Balancer"
  vpc_id      = aws_vpc.main_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permette traffico da CloudFront
    description = "Allow HTTP inbound from anywhere (for CloudFront)"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.alb_name}-sg" }
}

# =============================================================================
# TARGET GROUP
# =============================================================================
resource "aws_lb_target_group" "app_tg" {
  name        = var.alb_target_group_name
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "instance"
  health_check {
    enabled  = true
    path     = "/"
    matcher  = "200"
    interval = 30
  }
  tags = { Name = var.alb_target_group_name }
}

# =============================================================================
# LISTENER HTTP
# =============================================================================
# L'azione di default ora blocca il traffico. Il passaggio è gestito dalla regola.
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = "80"
  protocol          = "HTTP"

  # Azione di default: risponde con un errore 403 (Forbidden).
  # Questo impedisce l'accesso diretto all'ALB.
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Forbidden"
      status_code  = "403"
    }
  }
}

# =============================================================================
# REGOLA DEL LISTENER PER CLOUDFRONT
# =============================================================================
# Questa regola inoltra il traffico al Target Group SOLO SE la richiesta
# contiene l'header personalizzato inviato da CloudFront.
resource "aws_lb_listener_rule" "from_cloudfront" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = [var.cloudfront_secret_header_value]
    }
  }
}
