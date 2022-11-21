resource "aws_lambda_function" "playwright" {
  function_name = "playwright-aws-lambda"
  image_uri     = "${aws_ecr_repository.ecr_repo.arn}/${var.latest_image}"
  package_type  = "Image"
  role          = aws_iam_role.playwright_lambda.arn
  timeout       = "600"
  memory_size   = "3008"
  environment {
    variables = {
      "QA_BUCKET" = aws_s3_bucket.bucket.bucket
    }
  }
}
