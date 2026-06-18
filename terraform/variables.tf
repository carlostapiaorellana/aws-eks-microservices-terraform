# ---- General ----
variable "project_name" {
  type    = string
  default = "lab-it-support"
}
variable "environment" {
  type    = string
  default = "lab"
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "owner" {
  type    = string
  default = "carlos-tapia"
}

# ---- Network ----
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "public_subnets_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

# ---- EKS ----
variable "eks_cluster_version" {
  type    = string
  default = "1.31"
}
variable "eks_node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}
variable "eks_node_desired_size" {
  type    = number
  default = 2
}
variable "eks_node_min_size" {
  type    = number
  default = 1
}
variable "eks_node_max_size" {
  type    = number
  default = 3
}

# ---- RDS ----
variable "db_engine_version" {
  type    = string
  default = "15.00.4365.2.v1"
}
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "db_allocated_storage" {
  type    = number
  default = 20
}
variable "db_admin_username" {
  type    = string
  default = "sqladmin"
}

# ---- GitHub OIDC ----
variable "github_org" {
  type    = string
  default = "tu-usuario-github"
}
variable "github_repo" {
  type    = string
  default = "laboratorio-5"
}

# ---- Costos ----
variable "budget_limit_usd" {
  type    = number
  default = 50
}
variable "alert_email" {
  type    = string
  default = "[email protected]"
}
