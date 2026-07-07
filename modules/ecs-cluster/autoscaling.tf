resource "aws_autoscaling_group" "ec2" {
  for_each = var.capacity_providers

  name                = "${var.cluster_name}-${each.key}-asg"
  vpc_zone_identifier = each.value.subnet_ids
  desired_capacity    = each.value.desired_capacity
  max_size            = each.value.max_size
  min_size            = each.value.min_size

  launch_template {
    id      = aws_launch_template.ec2[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-${each.key}"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
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
    auto_scaling_group_arn = aws_autoscaling_group.ec2[each.key].arn
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}-cp"
  })
}
