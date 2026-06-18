output "trail_name" { value = aws_cloudtrail.main.name }
output "trail_bucket" { value = aws_s3_bucket.trail.id }
