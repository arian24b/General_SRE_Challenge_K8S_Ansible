# Project Documentation Summary

## Project Overview and Client Explanation

### What is the General SRE Challenge - K8s & Ansible GitOps?

This project implements a comprehensive **Infrastructure as Code (IaC)** solution using **GitOps principles** to deploy a production-ready **Kubernetes cluster** with an **IP Geolocation API** on **ArvanCloud**. It demonstrates SRE best practices for automated, scalable, and secure cloud infrastructure management.

### The Client: IP Geolocation API

The **client** is a **FastAPI-based web service** that provides IP geolocation functionality:

- **Technology Stack**: FastAPI (Python), PostgreSQL, Docker, Kubernetes
- **Features**:
  - RESTful API endpoints for IP geolocation queries
  - Asynchronous database operations with SQLAlchemy
  - Prometheus metrics integration
  - Health checks and monitoring
  - Containerized deployment with Helm charts

- **API Endpoints**:
  - `GET /geolocate/{ip_address}` - Geolocation lookup
  - `GET /health` - Health check
  - `GET /metrics` - Prometheus metrics

- **Architecture**: Clean architecture with separate layers for core logic, database, routers, schemas, and services.

### Overall Architecture

```
Git Push → CI/CD → ArvanCloud Infra → K8s Cluster → Application
     ↓        ↓         ↓            ↓          ↓
  Trigger Validation Provisioning  Deployment Health Check
```

**Key Components**:
- **Infrastructure**: ArvanCloud VMs (1 master + 2 workers)
- **Orchestration**: Kubernetes cluster with containerd runtime
- **Application**: FastAPI API with PostgreSQL database
- **Monitoring**: Prometheus + Grafana + AlertManager
- **Automation**: Terraform + Ansible + Helm + GitHub Actions

## Manual Implementation

### Prerequisites

**System Requirements**:
- macOS/Linux/Windows with WSL
- 8GB RAM, 50GB disk space, internet connection

**Tools Required**:
- Git 2.30+, Docker 20.10+, kubectl 1.25+, Helm 3.10+, Ansible 2.15+, Python 3.11+

**ArvanCloud Setup**:
1. Create account at https://www.arvancloud.ir/
2. Generate API key with IaaS permissions
3. Create SSH key pair: `ssh-keygen -t ed25519 -C "k8s-cluster"`
4. Upload public key to ArvanCloud as `k8s-ssh-key`

### Step-by-Step Manual Deployment

#### Step 1: Infrastructure Provisioning (Terraform + Ansible)

```bash
# 1. Clone repository
git clone <repository-url>
cd General_SRE_Challenge_K8S_Ansible

# 2. Set environment variables
export ARVAN_API_KEY="your_arvan_api_key"
export DOCKER_REGISTRY="your-registry.com"
export DOCKER_USERNAME="username"
export DOCKER_PASSWORD="password"

# 3. Provision infrastructure
cd infrastructure/ansible
./setup-environment.sh
ansible-playbook provision-infrastructure.yml
```

#### Step 2: Kubernetes Cluster Setup

```bash
# Install container runtime
ansible-playbook -i inventory_provisioned.ini install-containerd.yml

# Install Kubernetes components
ansible-playbook -i inventory_provisioned.ini install-kube.yml

# Initialize cluster
ansible-playbook -i inventory_provisioned.ini init-cluster.yml

# Join worker nodes
ansible-playbook -i inventory_provisioned.ini join-workers.yml
```

#### Step 3: Monitoring Stack Deployment

```bash
# Setup kubectl access
MASTER_IP=$(grep ansible_host inventory_provisioned.ini | head -1 | cut -d'=' -f2)
scp "root@$MASTER_IP:~/.kube/config" ~/.kube/config

# Deploy monitoring
cd ../../monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create namespace monitoring
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack -n monitoring
helm upgrade --install grafana grafana/grafana -n monitoring
```

#### Step 4: Application Deployment

```bash
# Build and push application
cd ../application/api
docker build -t "$DOCKER_REGISTRY/api:latest" .
echo "$DOCKER_PASSWORD" | docker login "$DOCKER_REGISTRY" -u "$DOCKER_USERNAME" --password-stdin
docker push "$DOCKER_REGISTRY/api:latest"

# Deploy with Helm
cd ..
helm dependency update helm/
helm upgrade --install api helm/ -set image.repository="$DOCKER_REGISTRY/api"
```

#### Step 5: Verification

```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A

# Access services
kubectl port-forward svc/api 8080:80 -n application
curl http://localhost:8080/health

kubectl port-forward svc/grafana 3000:80 -n monitoring
# Access Grafana at http://localhost:3000 (admin/prom-operator)
```

### Troubleshooting Common Issues

**Infrastructure Issues**:
```bash
# Check Ansible connectivity
ansible -i inventory_provisioned.ini all -m ping

# Debug playbooks
ansible-playbook provision-infrastructure.yml -v
```

**Kubernetes Issues**:
```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# View logs
kubectl logs deployment/api
kubectl describe pod <pod-name>
```

**Application Issues**:
```bash
# Check pod status
kubectl get pods -n application

# Port forward for testing
kubectl port-forward svc/api 8080:80
```

## GitOps Deployment with GitHub

### GitHub Actions Setup

**Repository Configuration**:
1. Go to repository Settings → Secrets and variables → Actions
2. Add all required secrets (see below)
3. Ensure workflows have appropriate permissions

**Automated Pipeline Flow**:

```
Git Push → GitHub Actions → ArvanCloud → K8s → Application
     ↓              ↓            ↓        ↓        ↓
Pull Request   Validation   Provisioning Deployment Health Check
Validation     (Lint/Test)  (Terraform)  (Helm)    (Tests)
```

**Key Workflows**:
- `ci-cd.yml`: Complete CI/CD pipeline (lint, test, build, deploy)

### Deployment Process

#### Initial Setup

```bash
# 1. Configure GitHub Secrets (see Required Secrets section)

# 2. Configure terraform.tfvars
cd infrastructure/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit with your ArvanCloud settings

# 3. Configure application values
# Edit application/helm/values.yaml with your registry/domain

# 4. Push to trigger deployment
git add .
git commit -m "Initial deployment"
git push origin main
```

#### Automated Deployment Flow

1. **Code Validation**: Lint, test, build Docker image
2. **Infrastructure Provisioning**: Terraform creates ArvanCloud resources
3. **Kubernetes Setup**: Ansible configures cluster
4. **Application Deployment**: Helm deploys API and monitoring
5. **Health Validation**: Automated testing and verification

#### Monitoring Deployment

```bash
# Check workflow status
gh workflow view ci-cd.yml
gh run list --limit 5

# View logs
gh run view <run-id> --log
```

### GitOps Benefits

- **Automated Deployments**: Push to main = automatic deployment
- **Version Control**: All infrastructure and config in Git
- **Audit Trail**: Complete deployment history
- **Rollback**: Easy revert via Git
- **Consistency**: Same process for all environments

## Required Secrets

### GitHub Secrets Configuration

**Via GitHub Web UI**:
1. Repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret below

**Via GitHub CLI**:
```bash
gh auth login
gh secret set SECRET_NAME -b "secret_value"
```

### Required Secrets List

| Secret | Description | How to Generate |
|--------|-------------|-----------------|
| `ARVAN_API_KEY` | ArvanCloud API key | Get from ArvanCloud Dashboard → API Keys |
| `SSH_PRIVATE_KEY` | SSH private key for cluster access | `cat ~/.ssh/id_ed25519` (after generating key pair) |
| `DB_USERNAME` | PostgreSQL username | `api_user` |
| `DB_PASSWORD` | PostgreSQL password | `openssl rand -base64 32` |
| `DB_NAME` | PostgreSQL database name | `ip_geolocation` |
| `GRAFANA_PASSWORD` | Grafana admin password | `openssl rand -base64 24` |
| `DOCKER_REGISTRY` | Container registry URL | `ghcr.io/your-username` |
| `DOCKER_USERNAME` | Registry username | Your GitHub username |
| `DOCKER_PASSWORD` | Registry password | GitHub Personal Access Token with packages scope |

### Additional Optional Secrets

| Secret | Purpose |
|--------|---------|
| `KUBECONFIG` | Base64-encoded kubeconfig (generated after infra setup) |
| `ARGOCD_PASSWORD` | ArgoCD admin password (if using ArgoCD) |
| `ARGOCD_SERVER` | ArgoCD server URL |

### Secret Security Best Practices

- **Rotation**: Rotate secrets every 90 days
- **Generation**: Use `openssl rand -base64` for passwords
- **Storage**: Never commit secrets to Git
- **Access**: Use environment-specific secrets for production
- **Permissions**: Limit secret access to necessary workflows

### Local Development Secrets

For local testing, create `.env` file (excluded from Git):

```bash
# .env
ARVAN_API_KEY=apikey_your_key_here
DB_USERNAME=api_user
DB_PASSWORD=local_password
DB_NAME=ip_geolocation
GRAFANA_PASSWORD=admin
```

---

## Quick Reference

### Access Deployed Services

```bash
# API
kubectl port-forward svc/api 8080:80 -n application
curl http://localhost:8080/health

# Grafana
kubectl port-forward svc/grafana 3000:80 -n monitoring
# http://localhost:3000 (admin/<GRAFANA_PASSWORD>)

# Prometheus
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n monitoring
# http://localhost:9090
```

### Emergency Commands

```bash
# Rollback deployment
kubectl rollout undo deployment/api -n application

# Scale down
kubectl scale deployment api -n application --replicas=0

# Check events
kubectl get events -A --sort-by='.lastTimestamp'
```

### Development Commands

```bash
# Local development
make install    # Install dependencies
make test      # Run tests
make lint      # Lint code
make build     # Build Docker image

# Infrastructure
make tf-init   # Init Terraform
make tf-plan   # Plan changes
make tf-apply  # Apply changes
```

This summary provides a complete overview of the project, from concept to deployment, with both manual and automated GitOps approaches.