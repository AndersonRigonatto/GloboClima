# acm.tf

# 1. O Recurso para CRIAR o certificado no ACM
resource "aws_acm_certificate" "cert" {
  # O provider "alias" é necessário porque certificados para o CloudFront
  # DEVEM estar na região us-east-1.
  provider = aws.us-east-1

  domain_name       = var.domain_name
  # Adicionamos o wildcard para cobrir subdomínios como 'api' ou 'www'
  subject_alternative_names = ["*.${var.domain_name}"]
  
  # O método de validação que usaremos. DNS é o mais fácil de automatizar.
  validation_method = "DNS"

  # Um ciclo de vida que garante que, ao renovar, um novo certificado
  # seja criado ANTES do antigo ser destruído, evitando indisponibilidade.
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name      = var.domain_name
    ManagedBy = "Terraform"
  }
}

# 2. O Recurso para CRIAR os registros de validação no Route 53
# O Terraform pega os dados de validação do recurso acima e cria os registros DNS.
resource "aws_route53_record" "cert_validation" {
  # Este "for_each" é uma forma avançada de criar um registro para cada
  # nome de domínio no certificado (o principal e os alternativos).
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
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

# 3. O Recurso para ESPERAR a validação ser concluída
# Este recurso depende do certificado e dos registros DNS. Ele pausa
# a execução do Terraform até que a AWS confirme que o certificado é válido.
resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us-east-1

  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}