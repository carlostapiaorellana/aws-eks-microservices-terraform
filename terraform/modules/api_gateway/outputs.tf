output "api_id" { value = aws_apigatewayv2_api.this.id }
output "api_endpoint" { value = aws_apigatewayv2_api.this.api_endpoint }
output "api_endpoint_hostname" { value = replace(aws_apigatewayv2_api.this.api_endpoint, "https://", "") }
output "api_arn" { value = aws_apigatewayv2_api.this.arn }
output "stage_name" { value = aws_apigatewayv2_stage.this.name }
output "execution_arn" { value = aws_apigatewayv2_api.this.execution_arn }
