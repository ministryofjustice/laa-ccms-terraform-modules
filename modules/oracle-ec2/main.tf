resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = local.create_iam ? aws_iam_instance_profile.ec2[0].name : var.instance_profile_name
  monitoring                  = var.monitoring
  ebs_optimized               = var.ebs_optimized
  associate_public_ip_address = false

  user_data                   = var.user_data
  user_data_replace_on_change = false

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  dynamic "cpu_options" {
    for_each = var.cpu_core_count != null ? [1] : []
    content {
      core_count       = var.cpu_core_count
      threads_per_core = var.cpu_threads_per_core
    }
  }

  lifecycle {
    ignore_changes = [
      ebs_block_device,
      user_data,
      user_data_replace_on_change,
    ]
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}
