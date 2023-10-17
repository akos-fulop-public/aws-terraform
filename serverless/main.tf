resource "aws_s3_bucket" "file_upload_bucket" {
  bucket = "akos-serverless-upload-bucket"
}


data "archive_file" "thumbail_lambda_script" {
  type        = "zip"
  source_file = "${path.module}/scripts/lambda.py"
  output_path = "thumbnail_lambda_payload.zip"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "create_logs_policy" {
  name = "lambda-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "iam_for_lambda" {
  name  = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "function_logging_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.create_logs_policy.arn
}


resource "aws_lambda_function" "thumbnail_creator_lambda" {
  filename = data.archive_file.thumbail_lambda_script.output_path
  function_name = "Thumbnail_creator_lambda"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "lambda.lambda_handler"
  runtime = "python3.10"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lamdba/${aws_lambda_function.thumbnail_creator_lambda.function_name}"

}
