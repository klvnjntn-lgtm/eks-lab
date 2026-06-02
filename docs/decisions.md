# Architecture Decisions

This document explains the major architectural decisions made throughout the project, including alternatives considered, reasoning behind each choice, and associated tradeoffs.

---

# Why Amazon EKS Instead of ECS?

## Decision

Use Amazon EKS as the container orchestration platform.

## Alternatives Considered

* Amazon ECS Fargate

* Amazon ECS EC2

## Rationale

The primary goal of this project was to gain hands-on experience with Kubernetes and modern cloud-native tooling.

While ECS provides a simpler operational model, EKS exposes concepts commonly used in platform engineering environments, including:

* Kubernetes resource management

* GitOps workflows

* Dynamic node provisioning

* Ingress management

* Cluster observability

The project prioritizes learning Kubernetes operational patterns rather than minimizing infrastructure complexity.

## Tradeoffs

Advantages:

* Industry-standard orchestration platform

* Rich ecosystem

* Greater deployment flexibility

* Portable workloads

Disadvantages:

* Increased operational complexity

* Larger learning curve

* More components to manage

---

# Why Karpenter Instead of Static Node Groups?

## Decision

Use Karpenter for dynamic node provisioning.

## Alternatives Considered

* Fixed-size node groups

* Cluster Autoscaler

## Rationale

Karpenter provisions nodes directly in response to unscheduled workload demand.

Benefits include:

* Faster scale-up times

* Better resource utilization

* Flexible EC2 instance selection

* Reduced idle infrastructure

This provides a more modern autoscaling approach compared to maintaining permanently allocated worker capacity.

## Tradeoffs

Advantages:

* Improved efficiency

* Lower unused capacity

* More intelligent scaling

Disadvantages:

* Additional operational complexity

* Additional component to troubleshoot

---

# Architecture Decisions

This document captures key engineering decisions made during the design and implementation of the platform, including alternatives considered, reasoning, and tradeoffs.

---

# Why IAM Roles for Service Accounts (IRSA)?

## Decision

Use IAM Roles for Service Accounts (IRSA) via EKS OIDC integration for workload authentication to AWS services.

## Alternatives Considered

* Static AWS credentials stored in Kubernetes Secrets

* EC2 instance profiles for all workloads

## Rationale

IRSA enables Kubernetes pods to assume AWS IAM roles dynamically based on service account identity.

This provides fine-grained, workload-level access control to AWS services such as SSM Parameter Store.

## Tradeoffs

Advantages:

* Eliminates long-lived credentials

* Strong workload-level identity isolation

* Native AWS integration with EKS OIDC

* Improved security posture

Disadvantages:

* Increased IAM configuration complexity

* More moving parts during setup

---

# Why AWS Systems Manager (SSM) for Secrets?

## Decision

Use AWS Systems Manager Parameter Store for secrets management.

## Alternatives Considered

* Kubernetes Secrets

* AWS Secrets Manager

* External Secrets Operator

## Rationale

SSM provides a simple, cost-effective solution for storing configuration values and secrets.

When combined with IRSA, Kubernetes workloads can securely retrieve secrets at runtime without embedding credentials.

## Tradeoffs

Advantages:

* Centralized secret storage

* AWS-native integration

* Lower cost compared to Secrets Manager

* Simple operational model

Disadvantages:

* Less advanced rotation features compared to Secrets Manager

* Manual lifecycle management for some parameters

---

# Why Checkov for Infrastructure Validation?

## Decision

Use Checkov to perform static analysis on Terraform infrastructure code.

## Alternatives Considered

* Manual code review only

* No compliance scanning

* Alternative IaC scanners (tfsec, cfn-nag)

## Rationale

Checkov provides early detection of infrastructure misconfigurations before deployment.

It is used as a development-time guardrail to improve baseline security hygiene.

## Tradeoffs

Advantages:

* Early detection of security issues

* Infrastructure-as-code validation

* Improved baseline security posture

Disadvantages:

* Generates false positives in lab environments

* Not all findings are enforced due to learning-focused tradeoffs

* Adds an additional tool in CI workflow

# Why GitOps with ArgoCD?

## Decision

Use ArgoCD as the deployment platform.

## Alternatives Considered

* Manual kubectl deployments

* GitHub Actions direct deployment

* Helm-only deployment workflow

## Rationale

Git repositories serve as the source of truth for cluster state.

ArgoCD continuously reconciles deployed resources with repository configuration.

Benefits include:

* Automated deployments

* Consistent cluster state

* Easier rollback capability

* Improved deployment visibility

* Reduced configuration drift

## Tradeoffs

Advantages:

* Version-controlled deployments

* Declarative operations

* Automated synchronization

Disadvantages:

* Additional platform component

* More repository management

* Learning curve for GitOps workflows

---

# Why CloudWatch and Grafana?

## Decision

Use Amazon CloudWatch for monitoring, logging, and alerting, with Grafana for dashboard visualization.

## Alternatives Considered

* Prometheus and Grafana

* CloudWatch only

* Third-party monitoring platforms

## Rationale

CloudWatch integrates natively with AWS services and provides centralized monitoring across the environment.

Monitoring coverage includes:

* EKS cluster metrics

* EC2 node metrics

* Application Load Balancer metrics

* RDS metrics

* Application logs

Grafana provides richer dashboarding and visualization capabilities while using CloudWatch as a data source.

This approach reduces operational overhead compared to maintaining a dedicated Prometheus infrastructure.

## Tradeoffs

Advantages:

* Native AWS integration

* Simplified operations

* Centralized metrics and logs

* Flexible visualization

Disadvantages:

* Increased reliance on AWS services

* Less customization than Prometheus-based solutions

---

# Why Amazon RDS Instead of Self-Managed PostgreSQL?

## Decision

Use Amazon RDS for database management.

## Alternatives Considered

* PostgreSQL running on EC2

* PostgreSQL running inside Kubernetes

## Rationale

Database administration was not a primary objective of the project.

Using RDS offloads responsibilities such as:

* Backups

* Patching

* Maintenance

* Failure recovery

This allows operational focus to remain on Kubernetes and platform engineering concepts.

## Tradeoffs

Advantages:

* Reduced operational burden

* Managed backups

* Improved reliability

Disadvantages:

* Higher infrastructure costs

* Less database-level customization

---

# Why Application Load Balancer?

## Decision

Use an AWS Application Load Balancer integrated through Kubernetes Ingress.

## Alternatives Considered

* Network Load Balancer

* Self-managed NGINX Ingress Controller

## Rationale

The AWS Load Balancer Controller integrates directly with EKS and automatically manages load balancer resources based on Kubernetes Ingress definitions.

Benefits include:

* Native AWS integration

* Layer 7 routing support

* Simplified ingress management

* Automatic target registration

## Tradeoffs

Advantages:

* Managed AWS service

* Reduced operational overhead

* Strong Kubernetes integration

Disadvantages:

* AWS-specific implementation

* Additional AWS service costs

---

# Why Terraform?

## Decision

Use Terraform for infrastructure provisioning.

## Alternatives Considered

* AWS Console

* CloudFormation

* Manual resource creation

## Rationale

Terraform provides a consistent and repeatable method for infrastructure deployment.

Benefits include:

* Infrastructure as Code

* Version control integration

* Reproducible environments

* Automated provisioning

The entire platform can be recreated from source-controlled configuration.

## Tradeoffs

Advantages:

* Repeatability

* Automation

* Improved change tracking

Disadvantages:

* State management requirements

* Additional tooling complexity

---

# Why Multi-AZ Deployment?

## Decision

Deploy infrastructure across multiple Availability Zones.

## Alternatives Considered

* Single Availability Zone deployment

## Rationale

Production systems should tolerate infrastructure failures whenever possible.

Distributing workloads across multiple Availability Zones reduces the impact of:

* Node failures

* Subnet failures

* Availability Zone outages

## Tradeoffs

Advantages:

* Higher availability

* Improved fault tolerance

Disadvantages:

* Increased cost

* Additional network complexity

---

# Summary

The architecture prioritizes scalability, resiliency, automation, and operational visibility while intentionally embracing Kubernetes-native tooling.

Several decisions increase operational complexity compared to simpler alternatives such as ECS. However, those tradeoffs provide exposure to technologies and operational patterns commonly encountered in modern platform engineering and cloud infrastructure environments.
