resource "aws_batch_job_definition" "main" {
  name = var.project_name
  type = "container"

  timeout {
    attempt_duration_seconds = 60
  }

  platform_capabilities = [var.computing_type]

  container_properties = <<CONTAINER_PROPERTIES
{
  "command": ["node", "index.js"],
  "image": "${aws_ecr_repository.main.repository_url}:latest",
  "fargatePlatformConfiguration": {
    "platformVersion": "LATEST"
  },
  "resourceRequirements": [
    {"type": "VCPU", "value": "0.25"},
    {"type": "MEMORY", "value": "512"}
  ],
  "environment": [
    {"name": "VARNAME", "value": "VARVAL"},
    {"name": "SQS_QUEUE", "value": "${module.sqs.queue.url}"},
    {"name": "REGION", "value": "${var.aws_region}"}
  ],  
  "executionRoleArn": "${aws_iam_role.main.arn}",
  "networkConfiguration" : {
    "assignPublicIp": "ENABLED"
  }
}
CONTAINER_PROPERTIES
}
