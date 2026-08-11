output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "availability_zone" {
  description = "Availability zone in which the instance was launched — use ec2 for co-located EBS volume resources"
  value       = aws_instance.ec2.availability_zone
}

output "iam_role_name" {
  description = "Name of the IAM role attached to the instance. Null when an external instance_profile_name was supplied."
  value       = local.create_iam ? aws_iam_role.ec2[0].name : null
}

output "instance_profile_name" {
  description = "Name of the IAM instance profile attached to the instance"
  value       = local.create_iam ? aws_iam_instance_profile.ec2[0].name : var.instance_profile_name
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ec2.private_ip
}
