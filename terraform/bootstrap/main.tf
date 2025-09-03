# Bloco de configuração do Terraform para o bootstrap.
# Note a ausência de um bloco "backend", pois este script
# usará o estado local para criar a infraestrutura do estado remoto.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configuração do provedor AWS.
provider "aws" {
  region = var.aws_region
}

# --- Variáveis de Entrada ---

variable "aws_region" {
  description = "A região da AWS onde os recursos serão criados."
  type        = string
  default     = "sa-east-1"
}

variable "s3_bucket_name" {
  description = "O nome globalmente único para o bucket S3 do estado do Terraform."
  type        = string
}

variable "dynamodb_table_name" {
  description = "O nome para a tabela DynamoDB de travamento de estado."
  type        = string
}


# --- Recursos a Serem Criados ---

# 1. Bucket S3 para armazenar o arquivo de estado (terraform.tfstate)
resource "aws_s3_bucket" "tfstate" {
  bucket = var.s3_bucket_name

  # Medida de segurança CRÍTICA: impede que um "terraform destroy"
  # acidental apague seu bucket de estado.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Storage"
    Project     = "GloboClima"
    ManagedBy   = "Terraform"
  }
}

# Habilita o versionamento no bucket S3.
# Essencial para recuperar estados anteriores em caso de corrupção ou erro.
resource "aws_s3_bucket_versioning" "tfstate_versioning" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Garante que a criptografia do lado do servidor esteja habilitada.
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_sse" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueia todo e qualquer acesso público ao bucket.
resource "aws_s3_bucket_public_access_block" "tfstate_pab" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# 2. Tabela DynamoDB para travamento de estado (state locking)
resource "aws_dynamodb_table" "tflock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST" # Ideal e mais barato para este caso de uso.

  # O Terraform exige que a chave de partição se chame "LockID".
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S" # S = String
  }

  # Medida de segurança CRÍTICA para evitar a exclusão acidental da tabela.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Lock"
    Project     = "GloboClima"
    ManagedBy   = "Terraform"
  }
}


# --- Saídas (Outputs) ---
# Exibe os nomes dos recursos criados após a execução.
output "s3_bucket_name" {
  description = "O nome do bucket S3 criado."
  value       = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_name" {
  description = "O nome da tabela DynamoDB criada."
  value       = aws_dynamodb_table.tflock.name
}