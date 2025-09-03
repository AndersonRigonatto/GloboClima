# acm.tf

# Busca a zona DNS do seu domínio principal no Route 53.
# Isso nos permite adicionar os registros de validação de forma automática.
data "aws_route53_zone" "main" {
  name = "globoclima.site" # Seu domínio principal
}

# 1. O recurso do Certificado ACM
# Este bloco descreve o certificado que queremos gerenciar.
resource "aws_acm_certificate" "api" {
  domain_name       = var.api_domain_name # Usa a variável de "api.globoclima.site"
  validation_method = "DNS"

  tags = {
    Name      = var.api_domain_name
    ManagedBy = "Terraform"
  }

  # O ciclo de vida 'prevent_destroy' é uma segurança extra para evitar
  # que o certificado seja acidentalmente excluído por um 'terraform destroy'.
  lifecycle {
    prevent_destroy = true
  }
}

# 2. O registro DNS para validação do certificado
# O Terraform pega as informações de validação do recurso acima e cria
# o registro CNAME necessário no Route 53.
resource "aws_route53_record" "cert_validation" {
  # for_each garante que criaremos um registro para cada validação necessária.
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.main.zone_id
}

# 3. O recurso de Validação
# Este recurso especial instrui o Terraform a esperar até que o registro DNS
# seja propagado e a AWS confirme a validação do certificado.
resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}