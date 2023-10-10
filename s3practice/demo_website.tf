resource "aws_s3_bucket" "demo_bucket" {
  bucket = "akos-website-demo"
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.demo_bucket.id
  key = "index.html"
  source = "${path.module}/index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_public_access_block" "demo_bucket_public_access" {
  bucket = aws_s3_bucket.demo_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "demo_bucket_policy" {
  bucket = aws_s3_bucket.demo_bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.demo_bucket.id}/*"
        }
      ]
    }
  )
  depends_on = [ aws_s3_bucket_public_access_block.demo_bucket_public_access ]
}

resource "aws_s3_bucket_website_configuration" "demo_bucket_website" {
  bucket = aws_s3_bucket.demo_bucket.id
  index_document {
    suffix = aws_s3_object.index_html.key
  }
}
