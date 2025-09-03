# variables.tf


variable "api_domain_name" {
  description = "O nome de domínio (host header) para o qual as regras do ALB respondem."
  type        = string
  default     = "api.globoclima.site"
}

variable "aws_region" {
  description = "A região da AWS onde os recursos serão criados."
  type        = string
  default     = "sa-east-1"
}