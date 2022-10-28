resource "aws_batch_compute_environment" "main" {
  compute_environment_name = var.project_name

  compute_resources {
    spot_iam_fleet_role = var.computing_type == "FARGATE_SPOT"  ? aws_iam_role.main.arn : null 

    max_vcpus = var.max_vcpus

    security_group_ids = [
      aws_security_group.main.id,
    ]

    subnets = var.private_subnets

    type = var.computing_type
  }

  service_role = aws_iam_role.main.arn
  type         = "MANAGED"
  depends_on = [
    aws_iam_role_policy_attachment.ecr,
    aws_iam_role_policy_attachment.batch
  ]
}
