resource "aws_ecr_repository" "this" {
  name = local.base_name
}
