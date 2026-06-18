variable "aws_region" {
  description = "Region AWS para el state backend"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto, prefijo de recursos"
  type        = string
  default     = "lab-it-support"
}
