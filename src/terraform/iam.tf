data "aws_iam_policy_document" "policy_document_to_access_s3" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject",
    "s3:PutObjectAcl"]
    resources = ["${aws_s3_bucket.bucket_s3.arn}", "${aws_s3_bucket.bucket_s3.arn}/*"]
  }
}

resource "aws_iam_policy" "policy_document_to_access_s3" {
  name        = "policy_${var.project}_${lookup(var.enviorment, var.env)}_to_access_bucket_s3"
  description = "This policy give access of the lambda function to put files inside of the bucket"
  policy      = data.aws_iam_policy_document.policy_document_to_access_s3.json
}

resource "aws_iam_role_policy_attachment" "policy_att_document_to_access_s3" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.policy_document_to_access_s3.arn
}
