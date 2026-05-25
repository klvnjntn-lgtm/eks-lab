# 🚀 Production-Grade AWS Architectures (ECS + EKS)
Overview

This repository demonstrates two production-style architectures on AWS:

ECS Fargate (Managed Simplicity)
EKS (Kubernetes Control + Scalability)

Both are designed to survive real-world failure scenarios:

Container crashes
Failed health checks
Availability Zone outages

---

## ⚔️ Architecture Comparison


| Feature    | ECS Fargate                    | EKS (Kubernetes)              |
| ---------- | ------------------------------ | ----------------------------- |
| Complexity | Low                            | High                          |
| Control    | Limited                        | Full                          |
| Scaling    | Managed                        | Karpenter (dynamic nodes)     |
| Deployment | Native rolling / blue-green    | ArgoCD (GitOps)               |
| Use Case   | Fast, cost-efficient workloads | Large-scale, flexible systems |

---

![ECS DIAGRAM](ecs-project/docs/AWS-DIAGRAM.png)


## 🐳 ECS Fargate Architecture

### 🧭 Architecture Summary

Client → Internet Gateway → ALB → ECS (Fargate) → RDS (Multi-AZ)

ALB distributes traffic across Availability Zones
ECS Fargate runs stateless containers with auto-recovery
RDS Multi-AZ ensures database failover
Private subnets isolate backend resources

[Deep Dive](ecs-project/docs/infrastructure.md)

### 💥 Challenges Faced
[View Challenges](ecs-project/docs/challenges.md)

### 🧠 Design Decisions
[View Decisions](ecs-project/docs/decisions.md)

### 🚀 Getting Started
[Installation Guide](ecs-project/docs/installation.md)

### 🔮 Future Improvements
[Future Plans](ecs-project/docs/future-projects.md)

### 🧱 Core Components

ECS Fargate — serverless container compute (no EC2 management)

ALB — Layer 7 routing with health checks

RDS (Multi-AZ) — high availability database

VPC Design — public + private subnet isolation

### 💥 Failure Handling

Container crash → ECS restarts task automatically

Failed health check → ALB stops routing traffic

AZ outage → traffic routed to healthy AZ

DB failure → automatic failover (RDS Multi-AZ)

### 🚀 Deployment

# 1. Clone your portfolio repository

```bash
git clone https://github.com/klvnjntn-lgtm/cloud-infrastructure-project-kj.git

cd cloud-infrastructure-project-kj
```

# 2. Deploy Infrastructure Layer First (VPC, EKS Cluster, Core Networking)

```bash
cd layers/infra

terraform init

terraform apply -auto-approve
``` 
# 3. Move to and Deploy Addons Layer (Karpenter, ArgoCD, Load Balancers)

```bash
cd ../addons

terraform init

terraform apply -auto-approve
```

### 🔄 Deployment Strategy

Rolling deployments via ECS
Blue/Green using dual target groups
Zero-downtime releases with health checks

---

## ☸️ EKS Architecture

### 🧭 Architecture Summary

Client → ALB → EKS Cluster → Pods → RDS

### 🧱 Core Components

#### ⚙️ Kubernetes (EKS)

Managed control plane via EKS

Workloads deployed as pods

#### 🚀 Karpenter (Autoscaling)

Dynamic node provisioning based on workload demand

Uses NodeClass + NodePool for flexible scaling

Eliminates need for managed node groups

#### 🔄 ArgoCD (GitOps)

Declarative deployments via Git

Automatic sync to cluster

Version-controlled infrastructure + apps

#### 📊 Observability (Grafana Stack)

Metrics: Prometheus

Visualization: Grafana dashboards

Cluster + application monitoring

### 🔁 Request Flow (EKS)

### 💥 Failure Handling

Pod crash → auto restart (Kubernetes)
Node failure → Karpenter provisions new node
AZ failure → multi-AZ cluster reschedules pods
Deployment failure → ArgoCD rollback

### 🔄 CI/CD (EKS GitOps Style)

GitHub Push
→ Image built & pushed to ECR
→ ArgoCD detects manifest change
→ Syncs deployment to cluster

### ⚖️ Tradeoffs

| Pros |

Full control over infrastructure
Kubernetes ecosystem
Advanced scaling (Karpenter)

| Cons |

Higher complexity
More moving parts
Requires deeper debugging knowledge

### 📊 Why ECS vs Kubernetes

#### 🧠 ECS vs EKS — When to Use What
    Choose ECS when:
        You want simplicity
        Small-to-medium scale apps
        Faster deployment cycles
    Choose EKS when:
        You need flexibility
        Large-scale systems
        Multi-service architectures
        Advanced autoscaling (Karpenter)

---

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_grafana"></a> [grafana](#requirement\_grafana) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ./modules/alb | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ./modules/ecr | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs | n/a |
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | ./modules/monitoring | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_rds"></a> [rds](#module\_rds) | ./modules/rds | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_budgets_budget.monthly_limit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/budgets_budget) | resource |
| [aws_iam_policy.enforce_mfa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy.ecs_task_secrets_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of AZs to deploy into | `list(string)` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | n/a | `string` | `"my-app-container"` | no |
| <a name="input_monthly_budget_limit"></a> [monthly\_budget\_limit](#input\_monthly\_budget\_limit) | n/a | `string` | `"10.0"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The prefix for all resources in this project | `string` | `"Kelvin-Cloud-Project"` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for the public subnets | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_active_target_groups"></a> [active\_target\_groups](#output\_active\_target\_groups) | n/a |
| <a name="output_alb_public_url"></a> [alb\_public\_url](#output\_alb\_public\_url) | The public URL to access Kelvin's Web Server |
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | n/a |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | n/a |
| <a name="output_ecs_task_definition_family"></a> [ecs\_task\_definition\_family](#output\_ecs\_task\_definition\_family) | n/a |
<!-- END_TF_DOCS -->
