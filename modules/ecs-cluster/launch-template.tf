locals {
  # Generate minimal ECS user_data for any provider that doesn't supply its own
  default_user_data = { for k, v in var.capacity_providers :
    k => base64encode(<<-EOT
      #!/bin/bash
      echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
      echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
    EOT
    )
  }
}

resource "aws_launch_template" "ec2" {
  for_each = var.capacity_providers

  name          = "${var.cluster_name}-${each.key}-lt"
  image_id      = each.value.image_id
  instance_type = each.value.instance_type
  ebs_optimized = true

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = each.value.instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = each.value.security_group_ids
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      encrypted             = each.value.ebs_encrypted
      kms_key_id            = each.value.kms_key_id
      volume_size           = each.value.root_volume_size
      volume_type           = "gp2"
    }
  }

  user_data = each.value.user_data != null ? each.value.user_data : local.default_user_data[each.key]

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.cluster_name}-${each.key}"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(var.tags, {
      Name = "${var.cluster_name}-${each.key}-volume"
    })
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}-lt"
  })
}
