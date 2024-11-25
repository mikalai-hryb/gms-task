data "http" "my_ip" { url = "https://ipinfo.io/ip" }

# get authorization credentials to push to ecr
data "aws_ecr_authorization_token" "this" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" { state = "available" }

data "aws_ssm_parameter" "ec2_ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

data "local_file" "ansible_playbook" {
  filename = "${path.module}/../ansible/playbook.yaml"
}

data "archive_file" "kind" {
  type        = "zip"
  source_dir  = "../kind"
  output_path = "../kind.zip"
}

data "archive_file" "k8s" {
  type        = "zip"
  source_dir  = "../k8s"
  output_path = "../k8s.zip"
}
