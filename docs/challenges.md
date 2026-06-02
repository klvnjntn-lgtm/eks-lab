# Implementation Challenges

This document captures the major challenges encountered during the implementation of the platform and the lessons learned while resolving them.

---

# Challenge: Karpenter Provisioning Failures

## Problem

During deployment, Karpenter was unable to provision worker nodes successfully.

Several symptoms appeared:

* NodeGroups remained inactive

* NodeClass resources failed to become ready

* Workloads remained unscheduled

* Expected EC2 instances were not being launched

As a result, the cluster was unable to scale dynamically as intended.

---

## Initial Investigation

Troubleshooting focused on several potential causes:

* IAM permissions

* Karpenter controller configuration

* EKS cluster configuration

* Kubernetes resource definitions

* AWS networking configuration

Individual resources appeared to be configured correctly, but Karpenter continued to fail during provisioning.

---

## Root Cause

The issue was ultimately caused by deployment ordering and infrastructure dependencies.

Initially, infrastructure resources and Kubernetes add-ons were provisioned together within a single Terraform layer.

This created situations where Karpenter-related resources were being deployed before all required infrastructure components were fully available and ready.

As a result:

* NodeClass resources could not resolve required dependencies

* Karpenter could not successfully provision nodes

* Cluster components became difficult to troubleshoot due to tightly coupled deployments

---

## Resolution

The solution was to separate the project into distinct deployment layers.

### Infrastructure Layer

Responsible for foundational AWS resources:

* VPC

* Subnets

* IAM Roles

* EKS Cluster

* Node Groups

* Networking Components

Directory:

```text
/infra
```

### Add-ons Layer

Responsible for Kubernetes platform components:

* Karpenter

* ArgoCD

* Grafana

* Additional cluster services

Directory:

```text
/addons
```

This ensured that platform add-ons were deployed only after the underlying infrastructure was fully operational.

---

## Outcome

After separating the deployment layers:

* NodeGroups became healthy

* NodeClass resources initialized successfully

* Karpenter provisioned EC2 instances correctly

* Workloads scheduled as expected

* Troubleshooting became significantly easier

The deployment process also became more modular and maintainable.

---

## Lessons Learned

### Deployment Order Matters

Many Kubernetes platform components depend on infrastructure resources that must already exist and be operational.

Deploying everything simultaneously can create hidden dependency issues.

### Separate Infrastructure from Platform Services

Keeping foundational infrastructure separate from cluster add-ons improves maintainability and reduces deployment complexity.

### Troubleshoot Systematically

Initial symptoms suggested Karpenter configuration issues, but the root cause was actually related to deployment architecture and dependency management.

This reinforced the importance of validating assumptions and investigating the entire deployment workflow rather than focusing solely on the component exhibiting failures.

---

## Future Improvements

Potential improvements include:

* Automated validation of infrastructure readiness before add-on deployment

* CI/CD pipeline stages for infrastructure and platform services

* Additional health checks during deployment

* More granular Terraform state separation
