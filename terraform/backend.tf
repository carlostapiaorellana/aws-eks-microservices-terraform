# ⚠️ REEMPLAZA estos valores con el output del bootstrap (backend_config_snippet)
terraform {
  backend "s3" {
    bucket         = "lab-it-support-tfstate-e6d7be25"
    key            = "lab-it-support/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lab-it-support-tfstate-lock"
    encrypt        = true
  }
}
