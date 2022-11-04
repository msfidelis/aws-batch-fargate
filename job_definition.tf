resource "aws_batch_job_definition" "main" {
  name = var.project_name
  type = "container"

  timeout {
    attempt_duration_seconds = var.job_timeout * 2
  }

  platform_capabilities = [
    var.computing_type
  ]

  propagate_tags = true

  container_properties = <<CONTAINER_PROPERTIES
{
  "command": ["node", "index.js"],
  "image": "${aws_ecr_repository.main.repository_url}:latest",
  "fargatePlatformConfiguration": {
    "platformVersion": "LATEST"
  },
  "resourceRequirements": [
    {"type": "VCPU", "value": "${var.vcpu}"},
    {"type": "MEMORY", "value": "${var.memory}"}
  ],
  "environment": [
    {"name": "SQS_QUEUE", "value": "${module.sqs.queue.url}"},
    {"name": "REGION", "value": "${var.aws_region}"},
    {"name": "JOB_TIMEOUT", "value": "${var.job_timeout}"}
  ],  
  "executionRoleArn": "${aws_iam_role.main.arn}",
  "networkConfiguration" : {
    "assignPublicIp": "ENABLED"
  },
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {},
    "secretOptions": []
  },
  "jobDefinitionArn": "${aws_iam_role.main.arn}",
  "jobRoleArn": "${aws_iam_role.main.arn}"
}
CONTAINER_PROPERTIES
}
