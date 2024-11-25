resource "aws_rds_cluster" "this" {
  count = var.db.create ? 1 : 0

  cluster_identifier        = local.base_name
  engine                    = var.db.engine
  engine_version            = var.db.version
  db_cluster_instance_class = "db.c6gd.medium"
  allocated_storage         = 20
  storage_type              = "gp3"
  storage_encrypted         = true
  skip_final_snapshot       = true
  deletion_protection       = false

  availability_zones     = values(aws_subnet.private)[*].availability_zone
  db_subnet_group_name   = aws_db_subnet_group.this[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]

  database_name   = var.db.name
  master_username = var.db.username
  master_password = var.db.password
  port            = var.db.port
}

resource "aws_db_subnet_group" "this" {
  count = var.db.create ? 1 : 0

  name       = local.base_name
  subnet_ids = values(aws_subnet.private)[*].id
}
