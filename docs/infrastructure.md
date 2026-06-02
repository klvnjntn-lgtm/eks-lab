![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-232F3E?logo=amazon-aws)
![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker)

# Infrastructure Deep Dive

## Overview

This project implements a production-style Kubernetes platform on AWS using Amazon EKS. The architecture is designed to provide scalability, fault tolerance, automated deployments, and centralized observability while maintaining separation between infrastructure and application concerns.

The platform combines managed AWS services with Kubernetes-native tooling to reduce operational overhead while retaining flexibility and control over workload deployment and cluster behavior.

---

## Architecture Goals

The infrastructure was designed around several primary objectives:

* High availability across multiple Availability Zones

* Automated workload scaling

* GitOps-based deployment management

* Infrastructure as Code through Terraform

* Centralized monitoring and observability

* Secure network segmentation

* OIDC and SSM

* Reduced manual operational effort

---

## Network Design

The environment is deployed within a dedicated Amazon VPC spanning multiple Availability Zones.

### Public Subnets

Public subnets host internet-facing components including:

* Application Load Balancer (ALB)

* NAT Gateway

Resources in public subnets have routes to the Internet Gateway, allowing external traffic to enter the environment.

### Private Subnets

Private subnets host:

* EKS worker nodes

* Kubernetes workloads

* Amazon RDS

Application workloads remain inaccessible directly from the internet, reducing the attack surface of the environment.

### Traffic Flow

Inbound traffic follows this path:

Client → Internet Gateway → ALB → Kubernetes Service → Pod → RDS

Only the Application Load Balancer is publicly exposed.

---

## EKS Cluster Design

### Control Plane

Amazon EKS provides a managed Kubernetes control plane.

AWS is responsible for:

* API server management

* etcd availability

* Control plane patching

* Control plane scaling

This reduces operational complexity compared to self-managed Kubernetes clusters.

### Worker Nodes

Application workloads run on EC2 instances provisioned dynamically through Karpenter.

Worker nodes are deployed across multiple Availability Zones to improve availability and reduce the impact of infrastructure failures.

### Kubernetes Workloads

Applications are deployed using Kubernetes Deployments.

Benefits include:

* Self-healing workloads

* Replica management

* Rolling updates

* Declarative configuration

If a pod becomes unhealthy, Kubernetes automatically replaces it to restore the desired state.

---

## Dynamic Scaling with Karpenter

Karpenter provides cluster autoscaling by provisioning EC2 instances when unscheduled workloads are detected.

Scaling workflow:

1. New workload requests resources

2. Scheduler detects insufficient capacity

3. Karpenter provisions suitable EC2 instances

4. Workloads are scheduled automatically

When demand decreases, unused nodes are terminated to reduce infrastructure cost.

Compared to traditional node groups, Karpenter provides:

* Faster scaling

* Flexible instance selection

* Improved resource utilization

* Reduced capacity waste

---

## Application Delivery

### GitOps Workflow

Application deployment follows a GitOps model using ArgoCD.

Git repositories serve as the single source of truth for cluster configuration.

Deployment process:

1. Changes are committed to Git

2. CI pipeline builds container image

3. Image is pushed to Amazon ECR

4. Kubernetes manifests are updated

5. ArgoCD detects repository changes

6. Cluster state is synchronized automatically

This approach improves deployment consistency and auditability.

### Container Registry

Application images are stored within Amazon ECR.

Benefits include:

* Private image storage

* AWS-native integration

* Simplified image management

* Version-controlled releases

---

## Database Layer

Amazon RDS provides managed relational database services for the application.

### Design Considerations

Using RDS removes responsibility for:

* Database patching

* Backup management

* Infrastructure maintenance

* Failure recovery operations

The database is deployed within private subnets and can only be accessed through controlled security group rules.

---

## High Availability Design

The architecture incorporates several mechanisms to improve availability.

### Multi-AZ Deployment

Resources are distributed across multiple Availability Zones.

Benefits include:

* Reduced single point of failure risk

* Improved workload resilience

* Continued operation during AZ outages

### Kubernetes Self-Healing

Failed containers are automatically restarted.

Failed pods are recreated to maintain the desired replica count.

### Load Balancing

The Application Load Balancer distributes requests across healthy application instances.

Unhealthy targets are removed automatically from request routing.

---

## Security Model

Security is implemented through multiple layers.

### Network Isolation

Application workloads and databases operate within private subnets.

Direct internet access is restricted.

### Security Groups

Traffic is controlled using least-privilege security group rules.

Examples include:

* ALB accepts inbound HTTPS traffic

* EKS nodes accept traffic only from approved sources

* RDS accepts connections only from application workloads

### IAM Integration

AWS IAM controls infrastructure access.

Kubernetes workloads can be granted AWS permissions without embedding long-lived credentials.

---

## Security Model

Security is implemented using a layered AWS-native approach combined with Kubernetes identity controls.

### Network Isolation

* All workloads run inside private subnets

* Only the Application Load Balancer is publicly exposed

* RDS is not directly accessible from the internet

### IAM Roles for Service Accounts (IRSA)

The cluster uses IAM Roles for Service Accounts (OIDC integration) to grant Kubernetes workloads AWS permissions.

This allows pods to assume scoped IAM roles without embedding static credentials.

Benefits include:

* Fine-grained permission control per workload

* No long-lived AWS credentials inside Kubernetes

* Improved security posture

* Native AWS identity integration with EKS OIDC provider

---

### Secrets Management

Secrets and sensitive configuration are stored in AWS Systems Manager (SSM) Parameter Store.

Access is granted through IAM Roles for Service Accounts (IRSA), allowing workloads to retrieve secrets securely at runtime.

This avoids:

* Hardcoded secrets in manifests

* Kubernetes secret sprawl

* Manual secret distribution

---

### Infrastructure Security Validation

Infrastructure is validated using Checkov during development.

Checkov scans Terraform configurations for misconfigurations such as:

* Overly permissive security groups

* Missing encryption settings

* Weak IAM policies

This is used as a **pre-deployment security guardrail**, though not all findings are currently enforced due to tradeoffs between strict compliance and practical lab implementation.

## Observability

### CloudWatch

CloudWatch collects metrics, logs, and operational data across the environment.

Monitoring coverage includes:

- EKS cluster health

- EC2 node utilization

- Application Load Balancer performance

- RDS metrics

- Application logs

CloudWatch Alarms are configured to notify operators when predefined thresholds are exceeded.

### Grafana

Grafana visualizes CloudWatch data through centralized dashboards.

Dashboards provide visibility into:

- Cluster health

- Resource consumption

- Application performance

- Infrastructure trends

### Operational Benefits

The observability stack helps:

- Detect failures quickly

- Identify performance bottlenecks

- Analyze resource utilization

- Support troubleshooting efforts

---

## Failure Scenarios

### Pod Failure

Kubernetes automatically replaces failed pods.

Service traffic continues to be routed to healthy replicas.

### Node Failure

Pods running on failed nodes are rescheduled to healthy nodes.

Karpenter provisions replacement capacity when necessary.

### Availability Zone Failure

Workloads continue operating from remaining Availability Zones.

Traffic is routed only to healthy application instances.

### Deployment Failure

ArgoCD allows rollback to previously known-good configurations stored in Git.

This reduces recovery time and deployment risk.

---

## Summary

This architecture demonstrates a modern Kubernetes platform built using managed AWS services and cloud-native tooling.

By combining Amazon EKS, Karpenter, ArgoCD, Cloudwatch, Grafana, and RDS, the platform provides automated scaling, resilient workload management, GitOps-driven deployments, and centralized observability while maintaining a strong foundation for future expansion.
