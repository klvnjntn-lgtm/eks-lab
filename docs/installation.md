# Installation & Setup

## Prerequisites

Ensure the following tools are installed and configured:

* AWS Account with sufficient IAM permissions

* Terraform (v1.x recommended)

* AWS CLI

* kubectl

* Helm

Optional but recommended:

* Git

* Docker

---

## Configure AWS Credentials

```bash
aws configure
```

Provide:

* AWS Access Key ID

* AWS Secret Access Key

* Default Region

* Output Format (default is acceptable)

Verify access:

```bash
aws sts get-caller-identity
```

---

## Clone Repository

```bash
git clone https://github.com/klvnjntn-lgtm/eks-lab.git

cd eks-lab
```

---

## Configuration

Update the budget notification email address in:

```hcl
budgets.tf
```

```hcl
subscriber_email_addresses = ["your-email@example.com"]
```

Review any Terraform variables before deployment.

---

## Initialize Terraform

```bash
terraform init
```

This downloads the required providers and initializes the Terraform backend.

---

## Review Execution Plan

```bash
terraform plan
```

Review the proposed changes carefully before applying.

---

## Deploy Infrastructure

```bash
terraform apply
```

Type:

```bash
yes
```

when prompted.

Provisioning may take 15–30 minutes depending on AWS resource creation times.

Major provisioning tasks include:

* VPC creation

* NAT Gateway deployment

* EKS control plane creation

* Worker node provisioning

* Amazon RDS deployment

* IAM role configuration

---

## Configure kubectl

After deployment, update your kubeconfig:

```bash
aws eks update-kubeconfig \
  --region <aws-region> \
  --name <cluster-name>
```

Verify cluster connectivity:

```bash
kubectl get nodes
```

Expected output should display worker nodes in a Ready state.

---

## Verify Cluster Components

Check system workloads:

```bash
kubectl get pods -A
```

Verify:

* CoreDNS

* kube-proxy

* VPC CNI

* Karpenter

* ArgoCD

* Cloudwatch

* Grafana

All critical pods should be Running.

---

## Access ArgoCD

Retrieve the ArgoCD LoadBalancer endpoint:

```bash
kubectl get svc -n argocd
```

Obtain the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d
```

Login through the ArgoCD UI.

---

## Access Grafana

Retrieve the Grafana service endpoint:

```bash
kubectl get svc -n monitoring
```

Open the LoadBalancer URL in a browser and authenticate using the configured credentials.

---

## Access the Application

Retrieve the Application Load Balancer endpoint:

```bash
kubectl get ingress
```

or

```bash
aws elbv2 describe-load-balancers
```

Open:

```bash
http://<alb-dns-name>
```

in a browser.

---

## Validation

Verify cluster health:

```bash
kubectl get nodes
kubectl get pods -A
kubectl get ingress
```

Verify application deployment:

```bash
kubectl get deployments
kubectl get services
```

Verify Karpenter:

```bash
kubectl get nodepools
kubectl get nodes
```

---

## Cleanup

Destroy all AWS resources:

```bash
terraform destroy
```

Type:

```bash
yes
```

when prompted.

Terraform will remove:

* EKS Cluster

* Worker Nodes

* Load Balancers

* RDS

* VPC Components

* IAM Resources

---

## Cost Awareness

This project deploys real AWS infrastructure and will incur charges while running.

### Major Cost Drivers

* Amazon EKS Control Plane

* EC2 Worker Nodes

* NAT Gateway

* Amazon RDS

* Application Load Balancer

* EBS Volumes

### Recommendation

Always run:

```bash
terraform destroy
```

after testing to avoid unnecessary charges.

For long-running environments, consider:

* Smaller EC2 instance types

* Single-AZ RDS (development only)

* Aggressive Karpenter consolidation policies

* Scheduled cluster shutdowns
