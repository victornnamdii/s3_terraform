resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.api_id
  parent_id   = var.parent_id
  path_part   = var.path_part
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = var.http_method
  authorization = var.authorization

  request_parameters = var.request_parameters
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.integration_uri

  request_templates = var.request_templates
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method" "additional_methods" {
  for_each = var.additional_methods

  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = each.key
  authorization = each.value.authorization

  request_parameters = each.value.request_parameters
}

resource "aws_api_gateway_integration" "additional_integrations" {
  for_each = var.additional_methods

  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = each.key
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value.integration_uri

  request_templates = each.value.request_templates
  passthrough_behavior = "WHEN_NO_MATCH"
}
