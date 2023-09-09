data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "role_${var.project}_${lookup(var.enviorment, var.env)}_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


data "archive_file" "lambda_code" {
  type        = "zip"
  source_dir  = ".././raw_data"
  output_path = "./src/raw_data/export/lambda_function.zip"
}


data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = ".././python_libs"
  output_path = "./src/raw_data/export/lambda_layer_python.zip"
}


resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = data.archive_file.lambda_layer.output_path
  source_code_hash    = data.archive_file.lambda_layer.output_base64sha256
  layer_name          = "lambda_layer_python"
  compatible_runtimes = ["python2.7", "python3.6", "python3.7", "python3.8", "python3.9"]
}


resource "aws_lambda_function" "test_lambda" {

  filename         = data.archive_file.lambda_code.output_path
  function_name    = "lambda_${var.project}_extract_data_api"
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  runtime     = "python3.8"
  memory_size = "256"
  handler     = "lambda_function.lambda_handler"
  timeout     = 200
  layers      = [aws_lambda_layer_version.lambda_layer.arn]

}

