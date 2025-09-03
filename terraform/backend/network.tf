# network.tf

# Vamos "importar" a VPC padrão da sua conta para não precisarmos criá-la.
# Se você tiver uma VPC customizada, podemos ajustar isso.
data "aws_vpc" "default" {
  default = true
}

# -----------------------------------------------------------------------------
# SECURITY GROUP PARA O APPLICATION LOAD BALANCER (ALB)
# Permite tráfego web da internet.
# -----------------------------------------------------------------------------
resource "aws_security_group" "alb_sg" {
  name        = "ALB-SG"
  description = "Permite trafego do ALB e acesso SSH para as instancias do ECS" 
  vpc_id      = data.aws_vpc.default.id

  # Regra de Entrada: Permite HTTP de qualquer lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra de Entrada: Permite HTTPS de qualquer lugar
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regra de Saída: Permite que o ALB envie tráfego para qualquer lugar dentro da VPC.
  # A segurança é garantida pela regra de entrada do SG do ECS.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "ALB-SG"
    ManagedBy = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# SECURITY GROUP PARA AS TAREFAS/CONTÊINERES DO ECS
# Só permite tráfego vindo do ALB.
# -----------------------------------------------------------------------------
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "ECS-Instances-SG"
  description = "Permite trafego do ALB e acesso SSH para as instancias do ECS"
  vpc_id      = data.aws_vpc.default.id

  # Regra de Entrada: A MÁGICA DA SEGURANÇA ACONTECE AQUI!
  # Permite tráfego em todas as portas TCP, mas SOMENTE se a origem
  # for um recurso que está dentro do nosso Security Group do ALB.
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Regra de Saída: Permite que os contêineres acessem a internet e outros
  # serviços da AWS (ECR, DynamoDB, etc.).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "ECS-Tasks-SG"
    ManagedBy = "Terraform"
  }
}