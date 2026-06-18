variable "cluster_name" { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_provider_url" { type = string }
variable "vpc_id" { type = string }
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "chart_version" {
  type    = string
  default = "1.8.4"
}
variable "namespace" {
  type    = string
  default = "kube-system"
}
variable "service_account_name" {
  type    = string
  default = "aws-load-balancer-controller"
}
