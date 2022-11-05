###################################################
###### DESCULPA A PREGUIÇA DO PEÃO KKKKKKKKK ######
###################################################

resource "null_resource" "build" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {

    command = <<EOT
ls -lha -S 
cd job/
docker build -t job .
docker image tag job:latest ${aws_ecr_repository.main.repository_url} 


aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

docker push ${aws_ecr_repository.main.repository_url}:latest 

EOT
  }

  depends_on = [
    aws_ecr_repository.main
  ]

}
