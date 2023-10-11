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

resource "aws_iam_role" "iam_for_lambda" {
  name  = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "thumbnail_creator_lambda" {
  filename = data.archive_file.thumbail_lambda_script.output_path
  function_name = "Thumbnail_creator_lambda"
  role = aws_iam_role.iam_for_lambda.arn
  handler = "lambda.lambda_handler"
  runtime = "python3.10"
}
