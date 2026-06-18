variable "distribution_name" { type = string }
variable "frontend_bucket_id" { type = string }
variable "frontend_bucket_arn" { type = string }
variable "frontend_bucket_regional_domain_name" { type = string }
variable "api_gateway_hostname" { type = string }
variable "price_class" {
  type    = string
  default = "PriceClass_100"
}
variable "default_root_object" {
  type    = string
  default = "index.html"
}
