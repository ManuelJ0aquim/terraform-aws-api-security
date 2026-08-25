# Zipa o código do backend automaticamente
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../src/index.py"
  output_path = "${path.module}/../src/index.zip"
}

# Role do IAM para execução da Lambda
resource "aws_iam_role" "lambda_role" {
  name = "api_waf_lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Permissões básicas de log no CloudWatch para a Lambda
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Recurso da Função Lambda
resource "aws_lambda_function" "api_backend" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "api-waf-backend"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.11"
  architectures    = ["arm64"]
}