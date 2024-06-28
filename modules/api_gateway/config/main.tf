resource "aws_api_gateway_rest_api" "api" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["EDGE"]
  }

  tags = var.tags
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_rest_api.api]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = var.stage_name

  lifecycle {
    create_before_destroy = true
  }

  description = "Deployment for stage ${var.stage_name}"
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name
}