##############################################################################
### LB
##############################################################################
resource "aws_security_group" "lb" {
  name_prefix = "lb-sg-"
  description = "Security group for Load Balancer."
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "lb_ingress_allow_https" {
  security_group_id = aws_security_group.lb.id
  description       = "Allow inbound HTTPS traffic for everyone."
  type              = "ingress"
  protocol          = "TCP"
  to_port           = 443
  from_port         = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_egress_allow_all" {
  security_group_id = aws_security_group.lb.id
  description       = "Allow all outbound traffic."
  type              = "egress"
  protocol          = "ALL"
  to_port           = 0
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

##############################################################################
### EC2
##############################################################################
resource "aws_security_group" "ec2" {
  name_prefix = "ec2-sg-"
  description = "Security group for EC2 instances."
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "ec2_ingress_allow_lb" {
  security_group_id        = aws_security_group.ec2.id
  description              = "Allow EC2 to accept traffic from LB."
  type                     = "ingress"
  protocol                 = "TCP"
  to_port                  = aws_lb_target_group_attachment.ec2.port
  from_port                = aws_lb_target_group_attachment.ec2.port
  source_security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "ec2_egress_allow_all" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow all outbound traffic."
  type              = "egress"
  protocol          = "ALL"
  to_port           = 0
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

##############################################################################
### RDS
##############################################################################
resource "aws_security_group" "rds" {
  count = var.db.create ? 1 : 0

  name_prefix = "db-sg-"
  description = "Security group for RDS database."
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "rds_ingress_allow_ec2" {
  count = var.db.create ? 1 : 0

  security_group_id        = aws_security_group.rds[0].id
  description              = "Allow RDS to accept traffic from EC2 on port ${var.db.port}."
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = var.db.port
  to_port                  = var.db.port
  source_security_group_id = aws_security_group.ec2.id
}
