locals {
  create_iam = var.instance_profile_name == null
}

resource "aws_iam_role" "ec2" {
  count                = local.create_iam ? 1 : 0
  name                 = var.iam_role_name
  path                 = "/"
  max_session_duration = 3600

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {}
    }]
  })

  tags = merge(var.tags, {
    Name = var.iam_role_name
  })
}

resource "aws_iam_instance_profile" "ec2" {
  count = local.create_iam ? 1 : 0
  name  = var.iam_role_name
  role  = aws_iam_role.ec2[0].name
  path  = "/"

  tags = merge(var.tags, {
    Name = var.iam_role_name
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  count      = local.create_iam ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "cw_logging" {
  count       = local.create_iam ? 1 : 0
  name        = "${var.iam_role_name}-cw-logging"
  description = "Allow EC2 instance to write CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
      ]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_logging" {
  count      = local.create_iam ? 1 : 0
  role       = aws_iam_role.ec2[0].name
  policy_arn = aws_iam_policy.cw_logging[0].arn
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = local.create_iam ? toset(var.additional_policy_arns) : toset([])

  role       = aws_iam_role.ec2[0].name
  policy_arn = each.value
}
