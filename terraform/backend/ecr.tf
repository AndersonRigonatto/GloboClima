# ecr.tf

# Repositório para o serviço de Autenticação
resource "aws_ecr_repository" "auth" {
  name = "globoclima-auth"

  # MUTABLE permite que você sobrescreva uma tag de imagem (ex: 'latest').
  # IMMUTABLE é mais seguro para produção, pois garante que uma tag nunca mude.
  # Vamos manter MUTABLE por enquanto para simplicidade.
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # Boa prática de segurança para escanear por vulnerabilidades
  }

  tags = {
    Name      = "globoclima-auth"
    ManagedBy = "Terraform"
  }
}

# Repositório para o serviço de Dados
resource "aws_ecr_repository" "data" {
  name                 = "globoclima-data"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "globoclima-data"
    ManagedBy = "Terraform"
  }
}

# Repositório para o serviço de Favoritos
resource "aws_ecr_repository" "favorites" {
  name                 = "globoclima-favorites"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name      = "globoclima-favorites"
    ManagedBy = "Terraform"
  }
}