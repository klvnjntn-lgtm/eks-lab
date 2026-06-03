## EKS Architecture

### Architecture Summary

Client → Application Load Balancer → EKS Cluster → Kubernetes Pods → RDS

This architecture demonstrates a production-style Kubernetes platform on AWS designed for scalability, resiliency, and automated operations.

The cluster leverages managed Kubernetes through Amazon EKS, dynamic node provisioning with Karpenter, GitOps deployments using ArgoCD, and centralized monitoring through Prometheus and Grafana.

[Deep Dive Documentation](docs/infrastructure.md)

---

## Core Components

### Amazon EKS

Provides a managed Kubernetes control plane while allowing full control over cluster workloads and configuration.

Key capabilities:

* Multi-AZ cluster deployment

* Self-healing workloads

* Declarative application management

* Native Kubernetes ecosystem integration

---

### Karpenter

Handles dynamic node provisioning based on workload demand.

Instead of maintaining fixed worker capacity, Karpenter automatically launches and terminates EC2 instances as application requirements change.

Benefits:

* Faster scaling response

* Reduced infrastructure waste

* Lower operational overhead

* Flexible instance selection

---

### ArgoCD

Implements a GitOps deployment model where Git serves as the source of truth.

Deployment workflow:

1. Application changes are committed to Git

2. ArgoCD detects repository updates

3. Cluster state is reconciled automatically

4. Applications are deployed consistently across environments

Benefits:

* Version-controlled deployments

* Automated synchronization

* Easier rollback capability

* Reduced manual intervention

---

## Observability Stack

### Cloudwatch

CloudWatch collects metrics, logs, and operational data across the environment.

### Grafana

Visualizes operational data through dashboards and alerts.

Monitoring coverage includes:

* Cluster health

* Node utilization

* Pod performance

* Application metrics

* Resource consumption

---

## Request Flow

1. Client sends request to the Application Load Balancer

2. ALB forwards traffic into the EKS cluster

3. Kubernetes Service routes traffic to healthy pods

4. Application processes the request

5. Database operations are handled by RDS

6. Response returns through the load balancer to the client

---

## Failure Handling

### Pod Failure

Kubernetes automatically recreates failed pods through Deployment controllers.

### Node Failure

Workloads are rescheduled onto healthy nodes while Karpenter provisions replacement capacity when required.

### Availability Zone Failure

Pods are redistributed across healthy Availability Zones to maintain service availability.

### Deployment Failure

ArgoCD allows rapid rollback to previously known-good application states.

---

## CI/CD Pipeline

GitHub Push

→ Application Build

→ Container Image Pushed to ECR

→ Kubernetes Manifest Updated

→ ArgoCD Detects Change

→ Cluster Synchronization

→ Application Deployment

This GitOps workflow separates build and deployment responsibilities while maintaining a fully auditable deployment history.

---

## Tradeoffs

### Advantages

* Full Kubernetes flexibility

* Rich ecosystem and tooling

* Advanced autoscaling with Karpenter

* GitOps deployment workflow

* Portable Kubernetes workloads

* Fine-grained operational control

### Challenges

* Increased architectural complexity

* Larger operational surface area

* Steeper learning curve

* More extensive troubleshooting requirements

* Higher infrastructure management overhead

---

### Challenges Faced

[View Challenges](docs/challenges.md)

### Design Decisions

[View Decisions](docs/decisions.md)

### Installation Guide

[Getting Started](docs/installation.md)

### Future Improvements

[Future Plans](docs/future-projects.md)

---

## When to Choose EKS

EKS is often the preferred choice when:

* Operating large-scale applications

* Managing multiple microservices

* Requiring advanced deployment patterns

* Standardizing on Kubernetes

* Building platform engineering capabilities

* Supporting multi-team environments

While ECS prioritizes operational simplicity, EKS provides greater flexibility and control for organizations requiring deeper Kubernetes capabilities.