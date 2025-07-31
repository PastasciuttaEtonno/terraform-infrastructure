# Definisce i provider richiesti dal modulo.
# Questo risolve i warning di Terraform.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}
