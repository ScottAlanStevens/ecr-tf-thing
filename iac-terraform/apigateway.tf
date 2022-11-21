resource "aws_api_gateway_rest_api" "gateway" {
  name = "Test Rest Api"
}

resource "aws_api_gateway_resource" "aws2" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  path_part   = "aws2"
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.aws2.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.aws2.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.aws2.id
  http_method             = aws_api_gateway_method.options_method.http_method
  integration_http_method = "OPTIONS"
  type                    = "MOCK"
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.gateway.id
  resource_id             = aws_api_gateway_resource.aws2.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  #   type                    = "AWS_PROXY"
  #   uri  = aws_lambda_function.magiclink-api.invoke_arn
  type = "MOCK"
}

resource "aws_api_gateway_stage" "stage" {
  depends_on = [
    aws_api_gateway_method.options_method,
    aws_api_gateway_method.post_method,
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_integration.post_integration,
  ]
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  deployment_id = aws_api_gateway_deployment.default.id
}

resource "aws_api_gateway_deployment" "default" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.aws2.id,

      aws_api_gateway_method.options_method.id,
      aws_api_gateway_method.post_method.id,

      aws_api_gateway_integration.options_integration.id,
      aws_api_gateway_integration.post_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}
