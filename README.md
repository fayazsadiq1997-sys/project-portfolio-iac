# project-portfolio-iac

Terraform for a containerised web application on AWS. This is Project A of a two-part
portfolio and covers the network and compute layers. The stack is a work in progress and
is not yet complete.

## Status

Built:

- Network module: VPC, public and private subnets, internet and NAT gateways, routing.
- Compute module (partial): ECR repository, CloudWatch log group, ECS cluster, task and
  execution IAM roles, task security group.

Not yet built:

- ECS and Fargate service.
- ALB.
- RDS database.
- CI/CD pipeline.

## Architecture

Region: `eu-west-2`.

### Network (`modules/network`)

- A `/16` VPC with two public and two private subnets across two availability zones.
  Availability zone names come from the `aws_availability_zones` data source rather than
  being hard-coded, so the module is not tied to a single region.
- Subnet CIDRs are derived from the VPC block with `cidrsubnet()` instead of being written
  by hand, so they stay consistent if the base block changes.
- Subnets use `for_each` over a map keyed by availability zone. Adding or removing an AZ is
  a change to `az_count`, not copied resource blocks.
- A single NAT gateway in the first public subnet gives the private subnets outbound
  access. One gateway rather than one per AZ keeps the running cost down. The trade is that
  private subnets lose outbound access if that AZ fails, which is acceptable for a dev
  environment but not for production.
- Public subnets route to the internet gateway; private subnets route to the NAT gateway.

### Compute (`modules/compute`)

- An ECR repository with image scanning on push.
- A CloudWatch log group for container logs, seven-day retention.
- Separate ECS execution and task roles. The execution role carries a least-privilege
  inline policy covering ECR pull and log writes only.
- A Fargate ECS cluster.
- A security group for task network interfaces, outbound 443 only at this stage.

## How to run

State and runs are managed in HCP Terraform. AWS access uses OIDC dynamic credentials, so
no long-lived access keys are stored.

```bash
terraform init
terraform plan
terraform apply
```

`terraform.tfvars` is gitignored. Copy `terraform.tfvars.example` to `terraform.tfvars`
for local variable values.

## Layout

```
.
├── main.tf              # Root module: wires network and compute together
├── providers.tf         # AWS provider, region
├── terraform.tf         # Backend and provider version constraints
├── outputs.tf           # Root outputs
└── modules
    ├── network          # VPC, subnets, gateways, routing
    └── compute          # ECR, logs, ECS cluster, IAM, security group
```

## Cost

Resources incur hourly cost outside the free tier, mainly the NAT Gateway. So the stack is always destroyed after build and documentation.
