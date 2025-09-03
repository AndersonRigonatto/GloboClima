# ecs-cluster.tf

# 1. O CLUSTER ECS
# Traduzido do output "describe-clusters".
resource "aws_ecs_cluster" "main" {
  name = "GloboClimaCluster"

  tags = {
    Name      = "GloboClimaCluster"
    ManagedBy = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# INFRAESTRUTURA EC2 (AUTO SCALING)
# -----------------------------------------------------------------------------

# Para robustez, buscamos a AMI mais recente otimizada para ECS em vez de
# usar um ID fixo ("ami-0e546fa5b95f157d1").
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# 2. O LAUNCH TEMPLATE
# Traduzido do output "describe-launch-template-versions".
resource "aws_launch_template" "main" {
  name = "ECSLaunchTemplate_8bPr9Olfe5HN"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = "t2.micro"

  iam_instance_profile {
    # Referencia o perfil de instância que já existe no seu arquivo iam.tf
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  vpc_security_group_ids = [
    # Referencia o security group que já existe no seu arquivo network.tf
    aws_security_group.ecs_tasks_sg.id
  ]

  # Script de inicialização, codificado em Base64 como no original.
  # Ele registra a instância no cluster ECS correto.
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
    EOF
  )

  tags = {
    Name      = "GloboClima-ECS-Template"
    ManagedBy = "Terraform"
  }
}

# 3. O AUTO SCALING GROUP
# Traduzido do output "describe-auto-scaling-groups".
resource "aws_autoscaling_group" "main" {
  name = "Infra-ECS-Cluster-GloboClimaCluster-c362a111-ECSAutoScalingGroup-MsdNxCGDD5rm"
  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  # Usa as sub-redes da sua VPC padrão, como no original.
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }

  # Adiciona uma tag de nome às instâncias criadas por este ASG.
  tag {
    key                 = "Name"
    value               = "ECS Instance - GloboClimaCluster"
    propagate_at_launch = true
  }

}

# -----------------------------------------------------------------------------
# INTEGRAÇÃO ENTRE ECS E AUTO SCALING GROUP (CAPACITY PROVIDER)
# -----------------------------------------------------------------------------

# 4. O CAPACITY PROVIDER
# Este recurso conecta formalmente o ASG ao Cluster ECS.
resource "aws_ecs_capacity_provider" "main" {
  name = "globoclima-asg-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.main.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

# 5. ASSOCIAÇÃO DO CLUSTER COM O CAPACITY PROVIDER
# Define o capacity provider criado acima como o padrão para o cluster.
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.main.name
  }
}