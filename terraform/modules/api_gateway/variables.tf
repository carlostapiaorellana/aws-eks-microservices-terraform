variable "api_name" { type = string }
variable "stage_name" {
  type    = string
  default = "$default"
}
variable "enable_access_logs" {
  type    = bool
  default = true
}
variable "log_retention_days" {
  type    = number
  default = 7
}
variable "alb_dns" {
  description = "DNS del ALB creado por el Ingress de Kubernetes"
  type        = string
}
