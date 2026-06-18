resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"
  description   = "HTTP API gateway for IT Support System"
  cors_configuration {
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_origins = ["*"]
    allow_headers = ["*"]
    max_age       = 3600
  }
  tags = { Name = var.api_name }
}

resource "aws_cloudwatch_log_group" "access_logs" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.api_name}"
  retention_in_days = var.log_retention_days
  tags              = { Name = "${var.api_name}-access-logs" }
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.access_logs[0].arn
      format = jsonencode({
        requestId        = "$context.requestId"
        ip               = "$context.identity.sourceIp"
        requestTime      = "$context.requestTime"
        httpMethod       = "$context.httpMethod"
        routeKey         = "$context.routeKey"
        status           = "$context.status"
        protocol         = "$context.protocol"
        responseLength   = "$context.responseLength"
        integrationError = "$context.integration.error"
      })
    }
  }

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }

  tags = { Name = "${var.api_name}-stage" }
}

# ============================================================================
# INTEGRACIONES
# ============================================================================
# HTTP API solo soporta integraciones proxy (AWS_PROXY o HTTP_PROXY).
#
# IMPORTANTE: separamos en DOS integraciones porque la variable {proxy}
# en la integration_uri DEBE existir en la route_key. La ruta /health
# no tiene {proxy}, asi que necesita su propia integracion sin variables.
#
# El path se reconstruye asi:
#   - Ruta:        ANY /api/{proxy+}
#   - Request:     /api/tickets/health
#   - {proxy}:     tickets/health
#   - URI final:   http://ALB/api/tickets/health  (matchea el Ingress)
# ============================================================================

# Variable con el DNS del ALB (se pasa desde mainprincipal.tf)
# Si prefieres hardcodearlo, reemplaza var.alb_dns por el DNS directo.

# Integracion para /api/* — pasa el path completo al ALB
resource "aws_apigatewayv2_integration" "api" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  integration_uri        = "http://${var.alb_dns}/api/{proxy}"
  payload_format_version = "1.0"
}

# Integracion para /health — sin variables de path
resource "aws_apigatewayv2_integration" "health" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "GET"
  integration_uri        = "http://${var.alb_dns}/api/tickets/health"
  payload_format_version = "1.0"
}

# ============================================================================
# RUTAS
# ============================================================================

# Ruta /api/{proxy+} → integracion api
resource "aws_apigatewayv2_route" "api_proxy" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.api.id}"
}

# Ruta /health → integracion health
resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.health.id}"
}
