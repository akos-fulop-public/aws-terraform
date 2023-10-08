resource "aws_s3_bucket" "website_bucket" {
  bucket = "akos-website-demo"
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.website_bucket.id
  key = "index.html"
  source = "${path.module}/index.html"
}
