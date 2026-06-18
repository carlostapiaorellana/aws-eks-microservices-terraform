variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnets_cidr" { type = list(string) }
variable "private_subnets_cidr" { type = list(string) }
variable "availability_zones" { type = list(string) }
variable "eks_cluster_name" { type = string }
variable "single_nat_gateway" {
  type    = bool
  default = true
}
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
