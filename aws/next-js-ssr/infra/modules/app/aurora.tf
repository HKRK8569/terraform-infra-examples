
# auroraのサブネットの指定
resource "aws_db_subnet_group" "aurora" {
  name       = "${var.name_prefix}-aurora-subnet-group"
  subnet_ids = module.network.private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-subnet-group"
  })
}

# auroraのSGの設定
resource "aws_security_group" "aurora" {
  name   = "${var.name_prefix}-aurora-sg"
  vpc_id = module.network.vpc_id

  ingress {
    description = "ECSからのみアクセスを許可する"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # TODO:ECSを定義後に設定を追加する
    security_groups = []
  }

  egress {
    description = "アウトバウンドを全て許可する"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-aurora-sg"
  })
}


# auroraの定義
resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.name_prefix}-postgres"
  engine             = "aurora-postgresql"
  engine_version     = "17.6"
  database_name      = var.db_name
  master_username    = var.db_username
  master_password    = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.aurora.id]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres"
  })
}

# writerの設定
resource "aws_rds_cluster_instance" "writer" {
  identifier          = "${var.name_prefix}-postgres-writer"
  cluster_identifier  = aws_rds_cluster.this.id
  count               = 1
  instance_class      = "db.t4g.micro"
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version
  publicly_accessible = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres-writer"
    Role = "writer"
  })
}

# readerの設定
resource "aws_rds_cluster_instance" "reader" {
  count               = 1
  identifier          = "${var.name_prefix}-postgres-reader-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = "db.t4g.micro"
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version
  publicly_accessible = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres-reader-${count.index + 1}"
    Role = "reader"
  })
}

