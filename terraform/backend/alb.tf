# alb.tf

# -----------------------------------------------------------------------------
# RECURSOS DO APPLICATION LOAD BALANCER (ALB)
# -----------------------------------------------------------------------------

# 1. O LOAD BALANCER PRINCIPAL
# Traduzido do output "describe-load-balancers".
resource "aws_lb" "main" {
  name               = "GloboClimaLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  
  # A referência ao security group já existe no seu arquivo network.tf.
  # O Terraform irá conectá-los automaticamente.
  security_groups    = [aws_security_group.alb_sg.id]

  # Em vez de fixar os IDs das sub-redes, buscamos dinamicamente todas as sub-redes
  # da sua VPC padrão. É uma prática mais robusta.
  subnets            = data.aws_subnets.default.ids

  tags = {
    Name      = "GloboClimaLoadBalancer"
    ManagedBy = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# TARGET GROUPS (GRUPOS DE DESTINO)
# -----------------------------------------------------------------------------
# Traduzido do output "describe-target-groups".

resource "aws_lb_target_group" "auth" {
  name        = "TargetGroup-AuthService"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/healthz"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "data" {
  name        = "TargetGroup-DataService"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/healthz"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group" "favorites" {
  name        = "TargetGroup-FavoritesService"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/healthz"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# -----------------------------------------------------------------------------
# LISTENER HTTPS E REGRAS DE ROTEAMENTO
# -----------------------------------------------------------------------------
# Traduzido dos outputs "describe-listeners" e "describe-rules".

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"

  # ALTERAÇÃO AQUI:
  # Antes: certificate_arn   = var.acm_certificate_arn
  # Agora:
  certificate_arn   = aws_acm_certificate_validation.api.certificate_arn

  # Ação padrão que retorna 404 se nenhuma regra for correspondida.
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = "{\"error\": \"Not Found\", \"message\": \"O caminho solicitado nao existe.\"}"
      status_code  = "404"
    }
  }
}

# Regra para o serviço de Dados
resource "aws_lb_listener_rule" "data" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.data.arn
  }

  condition {
    host_header {
      values = [var.api_domain_name]
    }
  }
  condition {
    path_pattern {
      values = ["/api/data/*"]
    }
  }
}

# Regra para o serviço de Autenticação
resource "aws_lb_listener_rule" "auth" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth.arn
  }

  condition {
    host_header {
      values = [var.api_domain_name]
    }
  }
  condition {
    path_pattern {
      values = ["/api/auth/*"]
    }
  }
}

# Regra para o serviço de Favoritos
resource "aws_lb_listener_rule" "favorites" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.favorites.arn
  }

  condition {
    host_header {
      values = [var.api_domain_name]
    }
  }
  condition {
    path_pattern {
      values = ["/api/favorites", "/api/favorites/*"]
    }
  }
}

# -------------------------------------------------------------------
# DNS record para apontar api.globoclima.site -> ALB
# -------------------------------------------------------------------
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.api_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}