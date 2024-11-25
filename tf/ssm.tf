data "aws_ssm_document" "apply_ansible_playbooks" {
  name            = "AWS-ApplyAnsiblePlaybooks"
  document_format = "JSON"
}

resource "aws_ssm_association" "apply_ansible_playbooks" {
  name = data.aws_ssm_document.apply_ansible_playbooks.name

  parameters = {
    SourceType          = "S3"
    SourceInfo          = jsonencode({ path = "https://${aws_s3_object.ansible_playbook.bucket}.s3.${var.region}.amazonaws.com/${aws_s3_object.ansible_playbook.key}" })
    InstallDependencies = "True"
    PlaybookFile        = "playbook.yaml"
    Verbose             = "-v"
    ExtraVariables = join(" ", [
      "region_name=${var.region}",
      "account_id=${data.aws_caller_identity.current.account_id}",
      "kind_s3_path=${aws_s3_object.kind.bucket}/${aws_s3_object.kind.key}",
      "k8s_s3_path=${aws_s3_object.k8s.bucket}/${aws_s3_object.k8s.key}",
      "image_name=${local.image_name}",
      "image_tag=${local.image_tag}",
    ])
  }

  targets {
    key    = "InstanceIds"
    values = [aws_instance.this.id]
  }

  lifecycle {
    replace_triggered_by = [
      aws_s3_object.ansible_playbook.etag,
      aws_s3_object.kind.etag,
      aws_s3_object.k8s.etag,
    ]
  }
}
