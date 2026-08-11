output "nlb_arn" {
  description = "ARN of the NLB"
  value       = aws_lb.nlb.arn
}

output "nlb_dns_name" {
  description = "DNS name of the NLB — used for Route53 alias records"
  value       = aws_lb.nlb.dns_name
}

output "nlb_zone_id" {
  description = "Hosted zone ID of the NLB — used for Route53 alias records"
  value       = aws_lb.nlb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group — pass to the ecs-service module load_balancer block"
  value       = aws_lb_target_group.nlb.arn
}
