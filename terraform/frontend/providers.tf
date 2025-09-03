# providers.tf

# --- Bloco de Configuração dos Provedores e Backend Remoto ---
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ADICIONE ESTE BLOCO COM OS NOMES DO SEU BUCKET E TABELA
  backend "s3" {
    bucket         = "globoclima-terraform-state-sa-east-1" # <== SEU NOME DO BUCKET
    key            = "frontend/terraform.tfstate" # <== Estado para o frontend
    region         = "sa-east-1"
    dynamodb_table = "terraform-state-lock" # <== SEU NOME DA TABELA
  }
}

# Provedor principal da AWS
provider "aws" {
  region = "sa-east-1"
}

# Provedor "alias" para o certificado do CloudFront em us-east-1
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}