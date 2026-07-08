resource "aws_efs_file_system" "efs" {
  encrypted        = true
  kms_key_id       = var.kms_key_id
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_efs_mount_target" "efs" {
  for_each = toset(var.subnet_ids)

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = var.security_group_ids
}
