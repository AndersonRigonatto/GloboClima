# ecs-services.tf

# -----------------------------------------------------------------------------
# DEFINIÇÕES DE TAREFA (TASK DEFINITIONS)
# -----------------------------------------------------------------------------
# Estas são as "receitas" base para seus serviços. O pipeline de CI/CD irá criar
# novas revisões a partir destas, atualizando a tag da imagem.

resource "aws_ecs_task_definition" "auth" {
  family                   = "AuthServiceTask"
  network_mode             = "bridge" # Padrão para EC2 launch type
  requires_compatibilities = ["EC2"]

  # Valores de CPU e Memória - AJUSTE CONFORME NECESSÁRIO
  cpu                      = "256"
  memory                   = "256"

  # Papel para o agente ECS (puxar imagem do ECR, enviar logs)
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  # Papel com as permissões da aplicação (acesso ao DynamoDB)
  task_role_arn = aws_iam_role.auth_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "globoclima-auth"
      # A imagem base. O CI/CD irá sobrescrever a tag "latest" com tags de commit.
      image     = "${aws_ecr_repository.auth.repository_url}:latest"
      cpu       = 256
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 5000 # Extraído do seu 'describe-services'
          hostPort      = 0    # Permite que o ECS escolha uma porta livre no host
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/globoclima-auth"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name      = "auth-service-task"
    ManagedBy = "Terraform"
  }
}

resource "aws_ecs_task_definition" "data" {
  family                   = "DataServiceTask"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  # O serviço de dados não tinha uma task role específica no seu iam.tf.

  container_definitions = jsonencode([
    {
      name      = "globoclima-data"
      image     = "${aws_ecr_repository.data.repository_url}:latest"
      cpu       = 256  
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/globoclima-data"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name      = "data-service-task"
    ManagedBy = "Terraform"
  }
}

resource "aws_ecs_task_definition" "favorites" {
  family                   = "FavoritesServiceTask"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.favorites_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "globoclima-favorites"
      image     = "${aws_ecr_repository.favorites.repository_url}:latest"
      cpu       = 256
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/globoclima-favorites"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name      = "favorites-service-task"
    ManagedBy = "Terraform"
  }
}

# -----------------------------------------------------------------------------
# SERVIÇOS ECS
# -----------------------------------------------------------------------------
# Estes recursos garantem que suas tarefas estejam rodando e conectadas ao Load Balancer.

resource "aws_ecs_service" "auth" {
  name            = "AuthService"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth.family
  desired_count   = 1 # Extraído do seu 'describe-services'

  # Usamos o capacity provider que definimos no ecs-cluster.tf
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
    base              = 0
  }

  # Configuração de deploy para rolling updates
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  # Conexão com o Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.auth.arn
    container_name   = "globoclima-auth"
    container_port   = 5000
  }
  
  # Garante que o serviço só seja criado/atualizado após a regra do ALB existir.
  depends_on = [aws_lb_listener_rule.auth]
}

resource "aws_ecs_service" "data" {
  name            = "DataService"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.data.family
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
    base              = 0
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.data.arn
    container_name   = "globoclima-data"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener_rule.data]
}

resource "aws_ecs_service" "favorites" {
  name            = "FavoritesService"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.favorites.family
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.main.name
    weight            = 1
    base              = 0
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.favorites.arn
    container_name   = "globoclima-favorites"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener_rule.favorites]
}

# Cria os grupos de log do CloudWatch para os contêineres
resource "aws_cloudwatch_log_group" "auth" {
  name = "/ecs/globoclima-auth"
}

resource "aws_cloudwatch_log_group" "data" {
  name = "/ecs/globoclima-data"
}

resource "aws_cloudwatch_log_group" "favorites" {
  name = "/ecs/globoclima-favorites"
}