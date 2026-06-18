variable "name_prefix" { type = string }
variable "budget_limit_usd" {
  type    = number
  default = 50
}
variable "alert_email" { type = string }
