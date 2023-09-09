resource "aws_s3_bucket" "bucket_s3" {
  bucket = "${var.project}-${lookup(var.enviorment, var.env)}"
  tags   = var.tags

}