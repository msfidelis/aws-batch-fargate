resource "aws_batch_job_queue" "main" {
  name = var.project_name

  scheduling_policy_arn = aws_batch_scheduling_policy.main.arn
  state                 = "ENABLED"
  priority              = 1

  compute_environments = [
    aws_batch_compute_environment.main.arn
  ]
}