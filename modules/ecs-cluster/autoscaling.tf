resource "aws_autoscaling_group" "ec2" {
  for_each = var.capacity_providers

  name                = "${var.cluster_name}-${each.key}-asg"
  vpc_zone_identifier = each.value.subnet_ids
  max_size            = each.value.max_size
  min_size            = each.value.min_size

  # ECS owns the desired capacity under managed scaling, and managed termination protection needs scale-in protection
  desired_capacity      = each.value.managed_scaling == null ? each.value.desired_capacity : null
  protect_from_scale_in = each.value.managed_scaling != null

  launch_template {
    id      = aws_launch_template.ec2[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-${each.key}"
    propagate_at_launch = true
  }

  # ECS adds AmazonECSManaged itself under managed scaling; declared here so Terraform does not remove it
  dynamic "tag" {
    for_each = merge(var.tags, { for k, v in { AmazonECSManaged = "" } : k => v if each.value.managed_scaling != null })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  for_each = var.capacity_providers

  name = "${var.cluster_name}-${each.key}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ec2[each.key].arn
    managed_termination_protection = each.value.managed_scaling != null ? "ENABLED" : "DISABLED"

    dynamic "managed_scaling" {
      for_each = each.value.managed_scaling != null ? [each.value.managed_scaling] : []
      content {
        status                    = "ENABLED"
        target_capacity           = managed_scaling.value.target_capacity
        minimum_scaling_step_size = managed_scaling.value.minimum_scaling_step_size
        maximum_scaling_step_size = managed_scaling.value.maximum_scaling_step_size
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}-cp"
  })
}
