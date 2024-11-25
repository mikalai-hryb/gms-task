resource "aws_s3_bucket" "assets" {
  bucket = "${local.base_name}-assets"
}

resource "aws_s3_object" "ansible_playbook" {
  bucket      = aws_s3_bucket.assets.bucket
  key         = "playbooks/playbook.yaml"
  content     = data.local_file.ansible_playbook.content
  source_hash = filemd5(data.local_file.ansible_playbook.filename)
}

resource "aws_s3_object" "kind" {
  bucket      = aws_s3_bucket.assets.bucket
  key         = "kind.zip"
  source      = data.archive_file.kind.output_path
  source_hash = data.archive_file.kind.output_base64sha256
}

resource "aws_s3_object" "k8s" {
  bucket      = aws_s3_bucket.assets.bucket
  key         = "k8s.zip"
  source      = data.archive_file.k8s.output_path
  source_hash = data.archive_file.k8s.output_base64sha256
}
