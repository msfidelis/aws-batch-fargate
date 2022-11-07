resource "aws_iam_instance_profile" "main" {
  name = format("%s-instance-profile", var.project_name)
  role = aws_iam_role.main.name
}

resource "aws_iam_role" "main" {
  name = format("%s-role", var.project_name)

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": [
            "batch.amazonaws.com",
            "ec2.amazonaws.com",
            "ecs-tasks.amazonaws.com",
            "ecs.amazonaws.com"
        ]
        
        }
    }
    ]
}
EOF
}

data "aws_iam_policy_document" "main" {
    version = "2012-10-17"

    statement {

        effect  = "Allow"
        actions = [
            "ecr:*",
            "sqs:*",
            "kms:*",
            "dynamodb:*",
            "ecs:List*", 
            "ecs:Describe*"
        ]

        resources = [ 
          "*"
        ]

    }
}

resource "aws_iam_policy" "main" {
  name        = var.project_name
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.main.json
}

resource "aws_iam_policy_attachment" "main" {
  name       = var.project_name

  roles      = [
    aws_iam_role.main.name
  ]

  policy_arn = aws_iam_policy.main.arn
}

resource "aws_iam_role_policy_attachment" "batch" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role" "cloudwatch" {
  name = format("%s-cloudwatch", var.project_name)

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
        "Service": [
            "events.amazonaws.com"
        ]
        
        }
    }
    ]
}
EOF
}


data "aws_iam_policy_document" "cloudwatch" {
    version = "2012-10-17"

    statement {

        effect  = "Allow"
        actions = [
            "batch:SubmitJob"
        ]

        resources = [ 
          "*"
        ]

    }
}

resource "aws_iam_policy" "cloudwatch" {
  name        = format("%s-cloudwatch", var.project_name)
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_iam_policy_attachment" "cloudwatch" {
  name       =  format("%s-cloudwatch", var.project_name)

  roles      = [
    aws_iam_role.cloudwatch.name
  ]

  policy_arn = aws_iam_policy.cloudwatch.arn
}