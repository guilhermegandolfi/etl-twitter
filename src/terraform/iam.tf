data "aws_iam_policy_document" "policy_document_to_access_s3" {
  statement {
    effect = "Allow"
    actions = ["s3:PutObject",
      "s3:PutObjectAcl", "s3:GetObject",
    "s3:ListBucket"]
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

###################################################################################################
## glue 
###################################################################################################
data "aws_iam_policy_document" "policy_document_glue_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "aws_iam_role_glue" {
  name               = "role_${var.project}_${lookup(var.enviorment, var.env)}_glue"
  assume_role_policy = data.aws_iam_policy_document.policy_document_glue_assume_role.json
  tags               = var.tags
}


resource "aws_iam_role_policy_attachment" "att_policy_glue_crawler" {
  role       = aws_iam_role.aws_iam_role_glue.name
  policy_arn = aws_iam_policy.policy_document_to_access_s3.arn

}

data "aws_iam_policy_document" "policy_document_glue_permission" {

  statement {
    sid    = "SidAllAcessObjectBucket"
    effect = "Allow"
    actions = [
      "glue:*",
    ]
    resources = ["*"]
  }


  statement {
    sid    = "SidAllAcessObjectBucketLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:/aws-glue/*"]
  }

}

resource "aws_iam_policy" "policy_glue_permission" {
  name   = "policy_${var.project}_${lookup(var.enviorment, var.env)}_glue_permission"
  policy = data.aws_iam_policy_document.policy_document_glue_permission.json
}

resource "aws_iam_role_policy_attachment" "att_policy_glue_permission" {
  role       = aws_iam_role.aws_iam_role_glue.name
  policy_arn = aws_iam_policy.policy_glue_permission.arn

}