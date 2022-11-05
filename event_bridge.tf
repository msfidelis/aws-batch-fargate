resource "aws_cloudwatch_event_rule" "main" {
  name        = var.project_name
  description = var.project_name

  schedule_expression = var.batch_scheduler
}


resource "aws_cloudwatch_event_target" "main" {
  rule = aws_cloudwatch_event_rule.main.name
  arn  = aws_batch_job_queue.main.arn

  role_arn = aws_iam_role.cloudwatch.arn
  batch_target {
    job_name       = var.project_name
    job_definition = aws_batch_job_definition.main.arn
    array_size     = var.batch_array_size
    job_attempts   = var.batch_attempts
  }

}

