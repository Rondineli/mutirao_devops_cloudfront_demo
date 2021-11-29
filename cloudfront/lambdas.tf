// Response from Origin
resource "aws_lambda_function" "origin_function_response" {
  filename         = data.archive_file.lambda_zip_origin_response.output_path
  source_code_hash = data.archive_file.lambda_zip_origin_response.output_base64sha256
  function_name    = "${var.environment}-${var.application}-response-function"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "main.handler"
  runtime          = "python3.8"
  publish          = true
}

// Prep to the origin request
resource "aws_lambda_function" "origin_function_request" {
  filename         = data.archive_file.lambda_zip_origin_request.output_path
  source_code_hash = data.archive_file.lambda_zip_origin_request.output_base64sha256
  function_name    = "${var.environment}-${var.application}-request-function"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "main.handler"
  runtime          = "python3.8"
  publish          = true
}

// Request from the viewer
resource "aws_lambda_function" "viewer_function_request" {
  filename         = data.archive_file.lambda_zip_viewr_request.output_path
  source_code_hash = data.archive_file.lambda_zip_viewr_request.output_base64sha256
  function_name    = "${var.environment}-${var.application}-viewer-request-function"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "main.handler"
  runtime          = "python3.8"
  publish          = true
}

// Response from origin to the viewer
resource "aws_lambda_function" "viewer_function_response" {
  filename         = data.archive_file.lambda_zip_viewr_response.output_path
  source_code_hash = data.archive_file.lambda_zip_viewr_response.output_base64sha256
  function_name    = "${var.environment}-${var.application}-viewer-response-function"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "main.handler"
  runtime          = "python3.8"
  publish          = true
}

data "archive_file" "lambda_zip_origin_request" {
  type        = "zip"
  output_path = "${path.module}/src/lambdas/origin_request/origin_request.zip"
  source_dir  = "${path.module}/src/lambdas/origin_request/"
}

data "archive_file" "lambda_zip_origin_response" {
  type        = "zip"
  output_path = "${path.module}/src/lambdas/origin_response/origin_response.zip"
  source_dir  = "${path.module}/src/lambdas/origin_response/"
}

data "archive_file" "lambda_zip_viewr_request" {
  type        = "zip"
  output_path = "${path.module}/src/lambdas/viewer_request/viewer_request.zip"
  source_dir  = "${path.module}/src/lambdas/viewer_request/"
}

data "archive_file" "lambda_zip_viewr_response" {
  type        = "zip"
  output_path = "${path.module}/src/lambdas/viewer_response/viewer_response.zip"
  source_dir  = "${path.module}/src/lambdas/viewer_response/"
}

resource "aws_lambda_permission" "allow_cf_origin_request" {
  depends_on    = [aws_lambda_function.origin_function_request]
  statement_id  = "AllowExecutionFromCfEdgefqq"
  action        = "lambda:*"
  function_name = aws_lambda_function.origin_function_response.function_name
  principal     = "edgelambda.amazonaws.com"
}

resource "aws_lambda_permission" "allow_cf_origin_response" {
  depends_on    = [aws_lambda_function.origin_function_response]
  statement_id  = "AllowExecutionFromCfEdgeofrs"
  action        = "lambda:*"
  function_name = aws_lambda_function.origin_function_response.function_name
  principal     = "edgelambda.amazonaws.com"
}

resource "aws_lambda_permission" "allow_cf_viewer_request" {
  depends_on    = [aws_lambda_function.viewer_function_request]
  statement_id  = "AllowExecutionFromCfEdgecfrq"
  action        = "lambda:*"
  function_name = aws_lambda_function.viewer_function_request.function_name
  principal     = "edgelambda.amazonaws.com"
}

resource "aws_lambda_permission" "allow_cf_viewer_response" {
  depends_on    = [aws_lambda_function.viewer_function_response]
  statement_id  = "AllowExecutionFromCfEdgevfrs"
  action        = "lambda:*"
  function_name = aws_lambda_function.viewer_function_response.function_name
  principal     = "edgelambda.amazonaws.com"
}
