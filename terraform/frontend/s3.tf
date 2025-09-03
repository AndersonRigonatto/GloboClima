# s3.tf

# Declara o recurso do bucket S3.
resource "aws_s3_bucket" "frontend_bucket" {
  # O nome exato do seu bucket funcional.
  bucket = "test-cdn-globoclima" # TROCAR POSTERIORMENTE
}

# Declara o recurso que gerencia o bloqueio de acesso público.
resource "aws_s3_bucket_public_access_block" "frontend_bucket_pab" {
  # Vincula este bloco de configurações ao bucket que criamos acima.
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json
}