# Ansible for Kubernetes Cluster Deployment

## Architecture

This Ansible setup follows best practices with a modular role-based structure:

```
ansible/
├── roles/
│   ├── install-containerd/    # Container runtime setup
│   ├── install-kubernetes/    # K8s components installation
│   ├── init-cluster/          # Cluster initialization
│   └── join-workers/          # Worker node joining
├── playbooks (*.yml)          # Orchestration playbooks
└── vars/                      # Configuration variables
```

## Files

### Playbooks
- `setup-cluster.yml`: **Master playbook** - orchestrates entire cluster setup
- `provision-infrastructure.yml`: Provision infrastructure on ArvanCloud
- `install-containerd.yml`: Install containerd runtime (uses role)
- `install-kube.yml`: Install Kubernetes tools (uses role)
- `init-cluster.yml`: Initialize cluster (uses role)
- `join-workers.yml`: Join workers to cluster (uses role)
- `deploy-monitoring.yml`: Deploy monitoring stack automatically
- `deploy-postgres.yml`: Deploy PostgreSQL cluster automatically
- `cleanup-infrastructure.yml`: Cleanup provisioned infrastructure

### Configuration
- `inventory.ini`: Static nodes list (for existing servers)
- `inventory_provisioned.ini`: Dynamically generated after provisioning
- `inventory_template.ini.j2`: Template for dynamic inventory
- `ansible.cfg`: Ansible settings
- `vars/arvancloud.yml`: ArvanCloud configuration variables

## Prerequisites
- ArvanCloud API key: `export ARVAN_API_KEY=your_api_key`
- SSH key pair created in ArvanCloud: `k8s-ssh-key`
- Ansible installed locally

### One-Command Setup
Use the master playbook to deploy everything:
```bash
# After provisioning infrastructure
ansible-playbook -i inventory_provisioned.ini setup-cluster.yml
```