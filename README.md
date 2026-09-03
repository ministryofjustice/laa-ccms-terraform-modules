# laa-ccms-terraform-modules

Reusable Terraform modules for CCMS (Client and Cost Management System) infrastructure, used across the CCMS applications hosted on the [Modernisation Platform](https://github.com/ministryofjustice/modernisation-platform-environments) (e.g. `ccms-soa`, `ccms-edrms`, `ccms-ebs`, `ccms-oia`, `ccms-pui`).

## Modules

| Module | Description |
|---|---|
| [alb](modules/alb) | Internal Application Load Balancer with HTTPS listener and target group |
| [ec2](modules/ec2) | Single EC2 instance with an IAM instance role/profile |
| [ecs-cluster](modules/ecs-cluster) | ECS cluster backed by one or more EC2 Auto Scaling capacity providers |
| [ecs-service](modules/ecs-service) | ECS task definition and service, with optional EFS and host-path volumes |
| [efs](modules/efs) | Encrypted EFS file system |
| [ftp](modules/ftp) | Lambda-based FTP/SFTP file transfer, with optional scheduled (cron) trigger |
| [nlb](modules/nlb) | Internal Network Load Balancer with TLS listener and target group |
| [rds](modules/rds) | RDS database instance with monitoring and event subscriptions |
| [waf](modules/waf) | WAFv2 web ACL (IP allowlist + managed rules) attached to an ALB |

Each module has its own `variables.tf` (inputs) and `outputs.tf` (outputs) — check those for the full, current interface before wiring it up.

## Usage

Reference a module from a consuming repo (e.g. an environment in `modernisation-platform-environments`) using the `//modules/<name>` subdirectory syntax, pinned to a commit SHA:

```hcl
module "rds" {
  # https://github.com/ministryofjustice/laa-ccms-terraform-modules/commit/<sha>
  source = "github.com/ministryofjustice/laa-ccms-terraform-modules//modules/rds?ref=<sha>"

  name       = "${local.component_name}-${local.env_label}"
  engine     = "postgres"
  # ...see modules/rds/variables.tf for the full set of inputs
  tags       = local.tags
}
```

**Always pin `ref` to a commit SHA, not a branch.** This repo has no release/tagging process yet, so a branch ref (e.g. `?ref=main`) is not stable and can change under a consumer without warning. Pin to the SHA of the commit you tested against, and put a comment with the commit URL above the `source` line so it's easy to see what changed on a version bump — this is the convention already used throughout `modernisation-platform-environments`.

To pick up a change, bump the `ref` (and the comment) in the consuming repo and re-run `terraform init -upgrade` for that module.

### Real-world example

The `ccms-feasibility` environment in `modernisation-platform-environments` is the reference consumer of these modules — see `terraform/environments/ccms-feasibility/ccms-soa` for `ecs-cluster`, `ecs-service`, `nlb`, `efs` and `rds` wired together, and `terraform/environments/ccms-feasibility/ccms-ebs` for `ftp` and `alb`.

## Requirements

- Terraform >= 1.0
- AWS provider >= 5.0

(See each module's `versions.tf`.)

## Development

- Keep modules focused: one AWS capability per module, composed together by the consuming environment rather than nested inside another module.
- Every input variable should have a `description`; add sensible `default`s only where a value is genuinely optional.
- Run `terraform fmt -recursive` and `terraform validate` (per module) before committing.
- When changing a module's interface (renaming/removing a variable or output), check known consumers in `modernisation-platform-environments` for breakage — since consumers pin to a SHA, existing deployments won't break automatically, but anyone bumping `ref` will need the update called out.
- Land changes on `main` via PR; consumers then pin to the merge commit's SHA.

## Contributing

Raise a PR against `main`. Since there's no tagging/release process, treat every commit on `main` as potentially "live" (something may pin to it shortly after merge) — keep changes small and self-contained.
