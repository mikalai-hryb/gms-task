locals {
  base_name     = "${var.domain}-${var.environment}-${var.role}"
  git_repo_root = "${path.root}/.."
  vpc_id        = aws_vpc.this.id

  my_ip   = data.http.my_ip.response_body
  my_cidr = "${local.my_ip}/32"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = var.environment
      Domain      = var.domain
      Name        = local.base_name
      Role        = var.role
    }
  }
}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.this.proxy_endpoint
    username = data.aws_ecr_authorization_token.this.user_name
    password = data.aws_ecr_authorization_token.this.password
  }
}
