module "sqs" {
    source      = "github.com/production-ready-toolkit/aws-sre-sqs"

    name                = var.project_name
    max_retry           = 3
    visibility_timeout  = 120
}