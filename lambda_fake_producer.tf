data "aws_iam_policy_document" "fake_data_assume_role" {

  version = "2012-10-17"

  statement {

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }

  }

}

data "aws_iam_policy_document" "fake_data" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:CreateNetworkInterface",
      "ec2:AttachNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "autoscaling:CompleteLifecycleAction"
    ]

    resources = [
      "*"
    ]

  }

  statement {

    effect = "Allow"
    actions = [
      "s3:*",
      "sqs:*"
    ]

    resources = [
      "*"
    ]

  }

  statement {

    effect = "Allow"
    actions = [
      "logs:*"
    ]

    resources = [
      "*"
    ]

  }


  statement {

    effect = "Allow"
    actions = [
      "kms:*"
    ]

    resources = [
      "*"
    ]

  }
}

resource "aws_iam_role" "fake_data" {
  name               = format("%s-fake-data", var.project_name)
  assume_role_policy = data.aws_iam_policy_document.fake_data_assume_role.json
}


resource "aws_iam_policy" "fake_lambda" {
  name        = format("%s-fake-data-policy", var.project_name)
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.fake_data.json
}

resource "aws_iam_policy_attachment" "fake_lambda" {
  name = "cluster_autoscaler"
  roles = [
    aws_iam_role.fake_data.name
  ]

  policy_arn = aws_iam_policy.fake_lambda.arn
}




resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "cd ./lambda/fake-data ; rm -rf node_modules && npm install --only=prod"
  }

  triggers = {
    release = timestamp()
  }
}

data "archive_file" "lambda_source_package" {
    type             = "zip"
    source_dir       = "./lambda/fake-data"
    output_path      = "fake-data-lambda.zip"
    output_file_mode = "0666"

    depends_on = [null_resource.install_dependencies]
}

resource "aws_lambda_function" "fake_data" {
  filename      = "fake-data-lambda.zip"
  function_name = format("%s-fake-data", var.project_name)
  role          = aws_iam_role.fake_data.arn
  handler       = "index.handler"
  timeout       = 120  

  source_code_hash = data.archive_file.lambda_source_package.output_md5

  runtime = "nodejs12.x"

  vpc_config {
    subnet_ids         = var.private_subnets
    security_group_ids = [
        aws_security_group.fake_data.id
    ]
  }
  
  environment {
    variables = {
      SQS_QUEUE             = module.sqs.queue.url
      NUMBER_OF_MESSAGES    = 1000
    }
  }
}

resource "aws_security_group" "fake_data" {
  name        = format("%s-fake-data", var.project_name)
  description = var.project_name

  vpc_id      = var.vpc_id


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_cloudwatch_event_rule" "fake_data" {
  name                = "fake-data-cron"
  schedule_expression = var.lambda_fake_cron
}

resource "aws_cloudwatch_event_target" "fake_data" {
  rule      = aws_cloudwatch_event_rule.fake_data.name
  target_id = "lambda"
  arn       = aws_lambda_function.fake_data.arn
}

resource "aws_lambda_permission" "fake_data" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fake_data.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.fake_data.arn
}