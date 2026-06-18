variable "db_identifier" { type = string }
variable "db_name" {
  type    = string
  default = "SupportDB"
}
variable "db_admin_username" {
  type    = string
  default = "sqladmin"
}
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "db_engine_version" {
  type    = string
  default = "15.00.4365.2.v1"
}
variable "db_allocated_storage" {
  type    = number
  default = 20
}
variable "vpc_id" { type = string }
variable "db_subnet_ids" { type = list(string) }
variable "allowed_cidrs" { type = list(string) }
variable "backup_retention_days" {
  type    = number
  default = 1
}
variable "skip_final_snapshot" {
  type    = bool
  default = true
}
variable "deletion_protection" {
  type    = bool
  default = false
}
