# outputs.tf

output "alb_dns_name" {
  description = "O endereço DNS público do Application Load Balancer."
  value       = aws_lb.main.dns_name
}