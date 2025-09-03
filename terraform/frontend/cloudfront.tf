# cloudfront.tf

# Declara o recurso de Controle de Acesso de Origem (OAC).
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "OAC-for-globoclima"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Este bloco recria a CDN.
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"

  # Os domínios que a CDN vai responder.
  aliases = [var.domain_name, "www.${var.domain_name}"]

  # Configuração da origem (o S3).
  origin {
    domain_name              = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id                = "S3-globoclima-frontend-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # Comportamento de cache padrão.
  default_cache_behavior {
    target_origin_id       = "S3-globoclima-frontend-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed policy: CachingOptimized
  }

  # Respostas de erro personalizadas para o Blazor.
  custom_error_response {
    error_code            = 403
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 0
  }
  custom_error_response {
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 0
  }

  # Configuração do certificado SSL.
  viewer_certificate {
    # Usa o ARN do certificado que buscamos com o "data source".
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Campo obrigatório para mostrar restrições geográficas, mesmo que não tenha nenhuma
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}