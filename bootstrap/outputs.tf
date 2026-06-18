output "state_bucket_name" {
  value = aws_s3_bucket.tfstate.id
}
output "lock_table_name" {
  value = aws_dynamodb_table.tfstate_lock.id
}
output "backend_config_snippet" {
  value = <<-EOT

    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.tfstate.id}"
        key            = "lab-it-support/terraform.tfstate"
        region         = "${var.aws_region}"
        dynamodb_table = "${aws_dynamodb_table.tfstate_lock.id}"
        encrypt        = true
      }
    }
  EOT
}
