# ============================================================================
# mainprincipal.tf — Orquestador completo (Fases 2-8)
# ============================================================================

# ---- FASE 2: Network ----
module "network" {
  source               = "./modules/network"
  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones
  eks_cluster_name     = local.eks_cluster_name
  single_nat_gateway   = true
  enable_nat_gateway   = true
}

# ---- FASE 3: Almacenamiento ----
module "s3_attachments" {
  source               = "./modules/s3"
  bucket_name          = local.attachments_bucket_name
  purpose              = "ticket-attachments"
  enable_cors          = true
  cors_allowed_origins = ["*"]
}

module "s3_frontend" {
  source             = "./modules/s3"
  bucket_name        = local.frontend_bucket_name
  purpose            = "frontend-hosting"
  versioning_enabled = true
  enable_cors        = false
}

module "ecr" {
  source        = "./modules/ecr"
  microservices = local.microservices
  name_prefix   = local.name_prefix
}

module "database" {
  source                = "./modules/database"
  db_identifier         = local.db_identifier
  db_name               = local.db_name
  db_admin_username     = var.db_admin_username
  db_instance_class     = var.db_instance_class
  db_allocated_storage  = var.db_allocated_storage
  db_engine_version     = var.db_engine_version
  vpc_id                = module.network.vpc_id
  db_subnet_ids         = module.network.private_subnet_ids
  allowed_cidrs         = [var.vpc_cidr]
  backup_retention_days = 1
  skip_final_snapshot   = true
  deletion_protection   = false
}

# ---- FASE 4A: EKS ----
module "eks" {
  source                       = "./modules/eks"
  cluster_name                 = local.eks_cluster_name
  cluster_version              = var.eks_cluster_version
  vpc_id                       = module.network.vpc_id
  subnet_ids                   = module.network.private_subnet_ids
  node_instance_types          = var.eks_node_instance_types
  node_desired_size            = var.eks_node_desired_size
  node_min_size                = var.eks_node_min_size
  node_max_size                = var.eks_node_max_size
  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]
}

# ---- FASE 4B: Load Balancer Controller + IRSA ----
module "lb_controller" {
  source            = "./modules/lb_controller"
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  vpc_id            = module.network.vpc_id
  aws_region        = var.aws_region
}

module "irsa_tickets_api" {
  source               = "./modules/irsa"
  role_name            = "${local.name_prefix}-tickets-api-sa"
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  namespace            = "default"
  service_account_name = "tickets-api-sa"
  inline_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = [module.database.db_secret_arn]
    }]
  })
}

module "irsa_files_api" {
  source               = "./modules/irsa"
  role_name            = "${local.name_prefix}-files-api-sa"
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  namespace            = "default"
  service_account_name = "files-api-sa"
  inline_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"]
        Resource = ["${module.s3_attachments.bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"]
        Resource = [module.s3_attachments.bucket_arn]
      }
    ]
  })
}

module "irsa_metrics_api" {
  source               = "./modules/irsa"
  role_name            = "${local.name_prefix}-metrics-api-sa"
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  namespace            = "default"
  service_account_name = "metrics-api-sa"
  inline_policy_json = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      Resource = [module.database.db_secret_arn]
    }]
  })
}

# ---- FASE 5: API Gateway + CloudFront ----
module "api_gateway" {
  source             = "./modules/api_gateway"
  api_name           = local.api_gateway_name
  enable_access_logs = true
  log_retention_days = 7
  alb_dns            = "k8s-default-itsuppor-0251dea0bd-1672347663.us-east-1.elb.amazonaws.com"
}

module "cloudfront" {
  source                               = "./modules/cloudfront"
  distribution_name                    = local.cloudfront_name
  frontend_bucket_id                   = module.s3_frontend.bucket_id
  frontend_bucket_arn                  = module.s3_frontend.bucket_arn
  frontend_bucket_regional_domain_name = module.s3_frontend.bucket_regional_domain_name
  api_gateway_hostname                 = module.api_gateway.api_endpoint_hostname
  price_class                          = "PriceClass_100"
}

module "frontend_deploy" {
  source            = "./modules/frontend_deploy"
  bucket_id         = module.s3_frontend.bucket_id
  cloudfront_domain = module.cloudfront.domain_name
}

# ---- FASE 8: Budget + CloudTrail + GitHub OIDC ----
module "budget" {
  source           = "./modules/budget"
  name_prefix      = local.name_prefix
  budget_limit_usd = var.budget_limit_usd
  alert_email      = var.alert_email
}

module "cloudtrail" {
  source      = "./modules/cloudtrail"
  name_prefix = local.name_prefix
}

module "github_oidc" {
  source      = "./modules/github_oidc"
  name_prefix = local.name_prefix
  github_org  = var.github_org
  github_repo = var.github_repo
}
