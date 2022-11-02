variable "project_name" {
  default = "aws-batch-demo"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-ba8b92c1"
}

variable "private_subnets" {
  type = list(any)
  default = [
    "subnet-29954875",
    "subnet-c832eeaf",
    "subnet-23a9760d"
  ]
}

variable "default_tags" {
  type = map(any)
  default = {
    PoC = "aws-batch"
  }
}

variable "instance_type" {
  type = list(any)
  default = [
    "c5a.large"
  ]
}

variable "computing_type" {
  type      = string
  default   = "FARGATE"
}

variable "max_vcpus" {
  type    = number
  default = 16
}

variable "min_vcpus" {
  type    = number
  default = 6
}

variable "lambda_fake_cron" {
  type = string
  default = "rate(1 minute)"
}