locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "Terraform"
    Repository  = "${var.github_org}/${var.github_repo}"
  }

  eks_cluster_name        = "${local.name_prefix}-eks"
  attachments_bucket_name = "${local.name_prefix}-attachments"
  frontend_bucket_name    = "${local.name_prefix}-frontend"
  db_identifier           = "${local.name_prefix}-mssql"
  db_name                 = "SupportDB"
  api_gateway_name        = "${local.name_prefix}-api"
  cloudfront_name         = "${local.name_prefix}-cdn"

  microservices = {
    tickets = "tickets-api"
    files   = "files-api"
    metrics = "metrics-api"
  }
}
