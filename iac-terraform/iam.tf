resource "aws_iam_role" "playwright_lambda" {
  name               = "playwright_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.playwright_lambda_policy.json
}

data "aws_iam_policy_document" "playwright_lambda_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy" "playwright_lambda" {
  name   = "${aws_iam_role.playwright_lambda.name}-policy"
  role   = aws_iam_role.playwright_lambda.id
  policy = data.aws_iam_policy_document.playwright_lambda_permissions.json
}

data "aws_iam_policy_document" "playwright_lambda_permissions" {
  version   = "2012-10-17"
  policy_id = "playwright_lambda_permissions"

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:CreateBucket",

      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",

      "lambda:InvokeFunction",
      "lambda:InvokeAsync",
    ]

    resources = [
      "arn:aws:logs:us-east-1:${data.aws_caller_identity.current.account_id}:*",
      "arn:aws:s3:::*/*",
    ]
  }
}
