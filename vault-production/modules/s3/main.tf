resource "aws_s3_bucket" "vault" {
  bucket        = var.bucket_name
  force_destroy = true
}
