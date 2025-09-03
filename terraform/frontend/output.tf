# outputs.tf

output "cloudfront_domain_name" {
  description = "O nome de domínio da distribuição do CloudFront."
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "website_url" {
  description = "A URL principal do site."
  value       = "https://www.${var.domain_name}"
}