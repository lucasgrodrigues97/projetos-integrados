# provider.tf is intentionally simple; credentials are expected via env vars or CI secrets
provider "aws" {
  region = var.aws_region
}
