# iam.tf

# -----------------------------------------------------------------------------
# POLÍTICAS DE CONFIANÇA (ASSUME ROLE POLICIES)
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "ecs_task_assume_role" {
  version = "2008-10-17" # Corresponde à versão existente
  statement {
    sid = "" # Adiciona o Sid em branco
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  version = "2008-10-17" # Corresponde à versão existente
  statement {
    sid = "" # Adiciona o Sid em branco
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# -----------------------------------------------------------------------------
# 1. PAPEL DE EXECUÇÃO DA TAREFA (TASK EXECUTION ROLE)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------------------------------------------------------
# 2. PAPEL DA INSTÂNCIA EC2 (EC2 INSTANCE ROLE)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecsInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecsInstanceRole"
  role = aws_iam_role.ecs_instance_role.name
}

# -----------------------------------------------------------------------------
# 3. PAPEL DA TAREFA DO SERVIÇO DE AUTENTICAÇÃO (AUTH TASK ROLE)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "auth_task_role" {
  name               = "ECSTaskAuthServiceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  description        = "Permite que a tarefa do serviço de autenticação acesse o DynamoDB."
}

data "aws_iam_policy_document" "auth_dynamodb_policy_document" {
  statement {
    sid    = "AllowDynamoDBAccessForAuthService"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = ["arn:aws:dynamodb:sa-east-1:590183663353:table/GloboClimaUsers"]
  }

  statement {
    sid       = "AllowListTablesForHealthCheck"
    effect    = "Allow"
    actions   = ["dynamodb:ListTables"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "auth_dynamodb_policy" {
  name        = "AuthServiceDynamoDBUsersTablePolicy"
  policy      = data.aws_iam_policy_document.auth_dynamodb_policy_document.json
}

resource "aws_iam_role_policy_attachment" "auth_dynamodb_attachment" {
  role       = aws_iam_role.auth_task_role.name
  policy_arn = aws_iam_policy.auth_dynamodb_policy.arn
}

# -----------------------------------------------------------------------------
# 4. PAPEL DA TAREFA DO SERVIÇO DE FAVORITOS (FAVORITES TASK ROLE)
# -----------------------------------------------------------------------------

resource "aws_iam_role" "favorites_task_role" {
  name               = "ECSTaskFavoritesServiceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  description        = "Permite que a tarefa do serviço de favoritos acesse o DynamoDB."
}

data "aws_iam_policy_document" "favorites_dynamodb_policy_document" {
  # Nota: Seu JSON original tinha uma permissão PutItem aqui, que não estava
  # no código C# que você me mostrou antes. Mantive para replicar 100%.
  statement {
    sid    = "AllowDynamoDBAccessForFavoritesService"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = ["arn:aws:dynamodb:sa-east-1:590183663353:table/GloboClimaFavorites"]
  }

  statement {
    sid       = "AllowListTablesForHealthCheck"
    effect    = "Allow"
    actions   = ["dynamodb:ListTables"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "favorites_dynamodb_policy" {
  name        = "FavoritesServiceDynamoDBFavoritesTablePolicy"
  policy      = data.aws_iam_policy_document.favorites_dynamodb_policy_document.json
}

resource "aws_iam_role_policy_attachment" "favorites_dynamodb_attachment" {
  role       = aws_iam_role.favorites_task_role.name
  policy_arn = aws_iam_policy.favorites_dynamodb_policy.arn
}






# Define o usuário IAM para o GitHub Actions
resource "aws_iam_user" "github_deployer" {
  name = "github-actions-deployer"
  path = "/"
}

# --- PERMISSÕES DO BACKEND (JÁ EXISTENTES) ---

# Anexa a política para permitir acesso total ao ECS
resource "aws_iam_policy_attachment" "ecs_full_access" {
  name       = "ecs-full-access-attachment"
  users      = [aws_iam_user.github_deployer.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# Anexa a política para permitir acesso de PowerUser ao ECR
resource "aws_iam_policy_attachment" "ecr_power_user" {
  name       = "ecr-power-user-attachment"
  users      = [aws_iam_user.github_deployer.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# --- PERMISSÕES DO FRONTEND (NOVAS) ---

# Cria uma política customizada para o deploy do frontend
resource "aws_iam_policy" "frontend_deploy_policy" {
  name        = "GitHubFrontendDeployPolicy"
  description = "Permite o deploy de arquivos no S3 e a invalidação do cache do CloudFront."

  # ATENÇÃO: Substitua os valores nos ARNs abaixo
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          "arn:aws:s3:::test-cdn-globoclima",
          "arn:aws:s3:::test-cdn-globoclima/*"
        ]
      },
      {
        Effect   = "Allow",
        Action   = "cloudfront:CreateInvalidation",
        Resource = "arn:aws:cloudfront::590183663353:distribution/E1NG7OS7GH9F73"
      }
    ]
  })
}

# Anexa a nova política do frontend ao usuário
resource "aws_iam_policy_attachment" "frontend_deploy_attachment" {
  name       = "frontend-deploy-policy-attachment"
  users      = [aws_iam_user.github_deployer.name]
  policy_arn = aws_iam_policy.frontend_deploy_policy.arn
}


# --- CHAVES DE ACESSO E SAÍDAS (JÁ EXISTENTES) ---

resource "aws_iam_access_key" "github_deployer_key" {
  user = aws_iam_user.github_deployer.name
}

output "access_key_id" {
  value       = aws_iam_access_key.github_deployer_key.id
  description = "The access key ID for the GitHub Actions deployer user."
}

output "secret_access_key" {
  value       = aws_iam_access_key.github_deployer_key.secret
  description = "The secret access key for the GitHub Actions deployer user."
  sensitive   = true
}