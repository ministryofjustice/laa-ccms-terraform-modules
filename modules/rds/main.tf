resource "aws_db_subnet_group" "db" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name}-subnet-group"
  })
}

resource "aws_db_option_group" "db" {
  count = length(var.options) > 0 ? 1 : 0

  name_prefix          = "${var.name}-og"
  engine_name          = var.engine
  major_engine_version = var.major_engine_version

  lifecycle {
    precondition {
      condition     = var.major_engine_version != null
      error_message = "major_engine_version must be set when options are specified."
    }
  }

  dynamic "option" {
    for_each = var.options
    content {
      option_name = option.value.option_name
      port        = option.value.port
      version     = option.value.version
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-og"
  })
}

resource "aws_db_instance" "db" {
  identifier     = var.name
  engine         = var.engine
  instance_class = var.instance_class

  allocated_storage          = var.allocated_storage
  storage_type               = var.storage_type
  iops                       = var.iops
  auto_minor_version_upgrade = true

  multi_az  = var.multi_az
  db_name   = var.db_name
  username  = var.username
  password  = var.password
  port      = var.port

  kms_key_id        = var.kms_key_id
  storage_encrypted = true

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.db.name
  option_group_name      = length(var.options) > 0 ? aws_db_option_group.db[0].name : null

  backup_retention_period             = var.backup_retention_period
  maintenance_window                  = var.maintenance_window
  backup_window                       = var.backup_window
  character_set_name                  = var.character_set_name
  license_model                       = var.license_model
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  iam_database_authentication_enabled = false

  enabled_cloudwatch_logs_exports = var.cloudwatch_log_exports

  tags = merge(var.tags, {
    Name                = var.name
    instance-scheduling = "skip-scheduling"
  })

  timeouts {
    create = "40m"
    delete = "40m"
    update = "80m"
  }

  lifecycle {
    ignore_changes = [engine_version]
  }
}
