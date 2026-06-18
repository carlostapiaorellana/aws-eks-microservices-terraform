variable "cluster_name" { type = string }
variable "cluster_version" {
  type    = string
  default = "1.31"
}
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "node_instance_types" {
  type    = list(string)
  default = ["t3.small"]
}
variable "node_desired_size" {
  type    = number
  default = 2
}
variable "node_min_size" {
  type    = number
  default = 1
}
variable "node_max_size" {
  type    = number
  default = 3
}
variable "node_disk_size" {
  type    = number
  default = 20
}
variable "endpoint_public_access" {
  type    = bool
  default = true
}
variable "endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
variable "cluster_log_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator"]
}
