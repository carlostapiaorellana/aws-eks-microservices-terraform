variable "role_name" { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_provider_url" { type = string }
variable "namespace" {
  type    = string
  default = "default"
}
variable "service_account_name" { type = string }
variable "policy_arns" {
  type    = list(string)
  default = []
}
variable "inline_policy_json" {
  type    = string
  default = ""
}
