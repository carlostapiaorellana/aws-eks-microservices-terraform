terraform {
  required_version = ">= 1.6.0, < 2.0.0"
  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.70" }
    random     = { source = "hashicorp/random", version = "~> 3.6" }
    tls        = { source = "hashicorp/tls", version = "~> 4.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.32" }
    helm       = { source = "hashicorp/helm", version = "~> 2.16" }
    null       = { source = "hashicorp/null", version = "~> 3.2" }
    http       = { source = "hashicorp/http", version = "~> 3.4" }
  }
}
