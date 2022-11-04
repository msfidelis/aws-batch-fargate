resource "aws_cloudwatch_event_rule" "main" {
  name                = var.project_name
  description         = "Stop instances nightly"
  schedule_expression = "cron(0 0 * * ? *)"
}