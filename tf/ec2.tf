resource "aws_instance" "this" {
  ami                    = data.aws_ssm_parameter.ec2_ami_id.value
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  subnet_id              = values(aws_subnet.private)[0].id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update
    sudo yum install docker -y
    sudo usermod -a -G docker ec2-user
    id ec2-user
    sudo newgrp docker
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
  EOF
}

###############################################################################
### IAM EC2 Role
###############################################################################

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name_prefix        = "${local.base_name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

resource "aws_iam_role_policy_attachment" "ec2_AmazonEC2ContainerRegistryPullOnly" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

# manages SSM agent which allows AWS Console connection
resource "aws_iam_role_policy_attachment" "ssm_AmazonSSMFullAccess" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_AmazonS3ReadOnlyAccess" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2" {
  name_prefix = "${local.base_name}-ec2"
  path        = "/ec2/instance/"
  role        = aws_iam_role.ec2.name
}
