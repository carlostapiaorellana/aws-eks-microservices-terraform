variable "bucket_name" { type = string }
variable "purpose" { type = string }
variable "versioning_enabled" {
  type    = bool
  default = true
}
variable "force_destroy" {
  type    = bool
  default = true
}
variable "enable_cors" {
  type    = bool
  default = false
}
variable "cors_allowed_origins" {
  type    = list(string)
  default = ["*"]
}
variable "lifecycle_expiration_days" {
  type    = number
  default = 0
}
