output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB — used for Route53 alias records"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of the ALB — used for Route53 alias records"
  value       = aws_lb.alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group — pass to the ecs-service module load_balancer block"
  value       = aws_lb_target_group.alb.arn
}

output "listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = aws_lb_listener.alb.arn
}
