locals {
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"

  policy_statements = concat(
    [
      {
        Effect   = "Allow"
        Action   = var.bucket_actions
        Resource = [local.bucket_arn, "${local.bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "${aws_cloudwatch_log_group.lambda.arn}:*"
      },
    ],
    length(var.secret_arns) == 0 ? [] : [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret", "secretsmanager:ListSecretVersionIds"]
      Resource = var.secret_arns
    }],
    length(var.kms_key_arns) == 0 ? [] : [{
      Effect   = "Allow"
      Action   = ["kms:GenerateDataKey*", "kms:Decrypt"]
      Resource = var.kms_key_arns
    }],
  )
}

# Security group

resource "aws_security_group" "lambda" {
  name        = "${var.name}-sg"
  description = "Controls access from the ${var.name} Lambda"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.name}-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "lambda_https" {
  for_each = toset(var.egress_cidr_blocks)

  security_group_id = aws_security_group.lambda.id
  description       = "Allow outbound HTTPS"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = each.value
}

# IAM role

resource "aws_iam_role" "lambda" {
  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = merge(var.tags, {
    Name = "${var.name}-role"
  })
}

resource "aws_iam_role_policy" "lambda" {
  name   = "${var.name}-policy"
  role   = aws_iam_role.lambda.id
  policy = jsonencode({ Version = "2012-10-17", Statement = local.policy_statements })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Function

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "/aws/lambda/${var.name}"
  })
}

resource "aws_lambda_function" "lambda" {
  function_name = var.name
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime
  timeout       = var.timeout
  memory_size   = var.memory_size
  publish       = true

  filename  = var.filename
  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  vpc_config {
    security_group_ids = [aws_security_group.lambda.id]
    subnet_ids         = var.subnet_ids
  }

  dynamic "environment" {
    for_each = length(var.environment_variables) == 0 ? [] : [1]
    content {
      variables = var.environment_variables
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })

  # The code is deployed outside Terraform; the package here only seeds the function
  lifecycle {
    ignore_changes = [source_code_hash, filename, s3_bucket, s3_key, handler]
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_vpc,
  ]
}

# S3 trigger

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = local.bucket_arn
}

resource "aws_s3_bucket_notification" "lambda" {
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = var.trigger.events
    filter_prefix       = var.trigger.filter_prefix
    filter_suffix       = var.trigger.filter_suffix
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}
