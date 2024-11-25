locals {
  tracked_files = setunion(
    fileset(local.git_repo_root, "docker/*"),
    fileset(local.git_repo_root, "src/*"),
    fileset(local.git_repo_root, "{Pipfile,Pipfile.lock}"),
  )
  dir_sha1 = sha1(join("",
    [for f in local.tracked_files : filesha1("${local.git_repo_root}/${f}")]
  ))
  image_name        = aws_ecr_repository.this.name
  image_tag         = local.dir_sha1
  tagged_image_name = "${local.image_name}:${local.image_tag}"
  fully_qualified_tagged_image_name = trimprefix(
    "${data.aws_ecr_authorization_token.this.proxy_endpoint}/${local.tagged_image_name}",
    "https://"
  )
}

# build image locally
resource "docker_image" "this" {
  name = local.fully_qualified_tagged_image_name
  build {
    context    = local.git_repo_root
    dockerfile = "${local.git_repo_root}/docker/Dockerfile"
    tag        = ["${local.image_name}:latest"]
  }

  # rebuild the docker image only if application files have changed
  triggers = { dir_sha1 = local.dir_sha1 }
}

# push image to Registry
resource "docker_registry_image" "this" {
  name = docker_image.this.name
}
