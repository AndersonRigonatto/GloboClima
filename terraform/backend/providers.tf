# providers.tf

# Este bloco configura o próprio Terraform, definindo os provedores necessários
# e, mais importante, onde o arquivo de estado será armazenado.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Trava a versão para evitar atualizações que quebrem o código
    }
  }

  # Configuração do estado remoto para colaboração e automação (CI/CD).
  backend "s3" {
    # SUBSTITUA pelo nome do bucket que você criou para o estado.
    bucket = "globoclima-terraform-state-sa-east-1"

    # Define o caminho/nome do arquivo de estado para o backend DENTRO do bucket.
    # Isso mantém o estado do backend separado do estado do frontend.
    key = "backend/terraform.tfstate"

    # Região onde o bucket S3 e a tabela DynamoDB estão localizados.
    region = "sa-east-1"

    # SUBSTITUA pelo nome da tabela DynamoDB que você criou para o lock.
    dynamodb_table = "terraform-state-lock"

    # Habilita a criptografia do arquivo de estado em repouso no S3.
    encrypt = true
  }
}

# Este é o seu provedor principal. Todos os recursos que não especificarem
# um "provider" diferente serão criados nesta região.
provider "aws" {
  region = "sa-east-1"
}

# Este é um provedor "alias" (apelido). Ele nos permite criar recursos em uma
# região diferente da principal. Pode ser útil para serviços globais ou
# específicos de uma região, como o ACM para o CloudFront.
# Manteremos ele aqui para consistência com seu projeto de frontend,
# embora os recursos do backend (ALB, ECS) usem certificados da mesma região (sa-east-1).
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}