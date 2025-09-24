# Projeto Infraestrutura + CI/CD (com Docker + AWS EC2 exemplo)

Este repositório é um template para sua entrega. Ele contém:
- `Dockerfile` → Exemplo de Dockerfile para uma aplicação frontend (React) ou static site.
- `infra/terraform/` → Scripts Terraform para provisionar recursos AWS (ECR, Security Group, EC2).
- `workflows/ci.yml` → Workflow que:
  1. Constrói uma imagem Docker e envia para Amazon ECR.
  2. Executa checks Terraform (fmt/validate/plan) e aplica na branch `main` (se configurado).

## O que você precisa configurar nos Secrets do GitHub Actions
- `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` → credenciais com permissão para ECR, EC2 e IAM se necessário.
- `AWS_REGION` → ex: `us-east-1`.
- `AWS_ACCOUNT_ID` → número da conta AWS (usado para formar o URI do ECR).
- `ECR_REPOSITORY_NAME` → nome do repo ECR (ex: `c4model-app-repo`).

## Como usar localmente (Terraform)
```bash
cd infra/terraform
terraform init
terraform plan
terraform apply -auto-approve
```

## Observações
- Este repositório é um **exemplo educacional**. Em produção você deve adicionar:
  - Gerenciamento de chaves/roles (IAM roles para instâncias puxarem imagens do ECR).
  - RDS (MySQL) e Security Groups refinados.
