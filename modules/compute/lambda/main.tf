variable "function_name" {
  description = "Lambda function name"
}

resource "aws_iam_role" "this" {
 name   = "iam_role_lambda_function"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM policy for logging from a lambda
resource "aws_iam_policy" "lambda_logging" {

  name         = "iam_policy_lambda_logging_function"
  path         = "/"
  description  = "IAM policy for logging from a lambda"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policy Attachment on the role.
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role        = aws_iam_role.this.name
  policy_arn  = aws_iam_policy.lambda_logging.arn
}

# Generates an archive from content, a file, or a directory of files.
data "archive_file" "default" {
  type        = "zip"
  source_file  = "${path.module}/index.js"
  output_path = "${path.module}/lambda_function.zip"
}

# Create a lambda function
# In terraform ${path.module} is the current directory.
resource "aws_lambda_function" "lambda_function" {
  filename                       = "${path.module}/lambda_function.zip"
  function_name                  = var.function_name //"lambda_authorizer"
  role                           = aws_iam_role.this.arn
  handler                        = "index.handler"
  runtime                        = "nodejs16.x"
  depends_on                     = [aws_iam_role_policy_attachment.policy_attach]
}