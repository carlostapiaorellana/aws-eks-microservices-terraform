# ---- Network ----
output "vpc_id" { value = module.network.vpc_id }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
output "public_subnet_ids" { value = module.network.public_subnet_ids }
output "nat_gateway_public_ips" { value = module.network.nat_gateway_public_ips }

# ---- Storage ----
output "attachments_bucket_name" { value = module.s3_attachments.bucket_id }
output "frontend_bucket_name" { value = module.s3_frontend.bucket_id }
output "ecr_repository_urls" { value = module.ecr.repository_urls }

# ---- Database ----
output "db_endpoint" {
  value     = module.database.db_endpoint
  sensitive = true
}
output "db_secret_arn" { value = module.database.db_secret_arn }
output "db_secret_name" { value = module.database.db_secret_name }

# ---- EKS ----
output "eks_cluster_name" { value = module.eks.cluster_name }
output "eks_cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}
output "eks_oidc_provider_arn" { value = module.eks.oidc_provider_arn }
output "kubectl_config_command" { value = module.eks.kubectl_config_command }

# ---- IRSA ----
output "lb_controller_role_arn" { value = module.lb_controller.iam_role_arn }
output "irsa_tickets_api_role_arn" { value = module.irsa_tickets_api.role_arn }
output "irsa_files_api_role_arn" { value = module.irsa_files_api.role_arn }
output "irsa_metrics_api_role_arn" { value = module.irsa_metrics_api.role_arn }

# ---- API Gateway + CloudFront ----
output "api_gateway_endpoint" { value = module.api_gateway.api_endpoint }
output "cloudfront_domain" {
  description = "URL FINAL DE LA APP"
  value       = "https://${module.cloudfront.domain_name}"
}
output "cloudfront_distribution_id" { value = module.cloudfront.distribution_id }

# ---- GitHub OIDC ----
output "github_actions_role_arn" {
  description = "ARN del rol para GitHub Actions (ponlo como secret/variable AWS_ROLE_ARN)"
  value       = module.github_oidc.role_arn
}

# ---- Comandos utiles ----
output "useful_commands" {
  value = {
    kubectl_config   = module.eks.kubectl_config_command
    open_app         = "start https://${module.cloudfront.domain_name}"
    get_db_password  = "aws secretsmanager get-secret-value --secret-id ${module.database.db_secret_name} --query SecretString --output text"
    invalidate_cache = "aws cloudfront create-invalidation --distribution-id ${module.cloudfront.distribution_id} --paths '/*'"
  }
}
