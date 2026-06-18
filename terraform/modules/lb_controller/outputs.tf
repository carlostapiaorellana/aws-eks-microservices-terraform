output "iam_role_arn" { value = module.lbc_irsa.role_arn }
output "iam_policy_arn" { value = aws_iam_policy.lbc.arn }
output "helm_release_name" { value = helm_release.lbc.name }
