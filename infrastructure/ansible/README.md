# Ansible for deploying a Kubernetes cluster

## Files:
- `inventory.ini`: Nodes list
- `ansible.cfg`: Ansible settings
- `install-containerd.yml`: install containerd
- `install-kube.yml`: install Kubernetes tools
- `init-cluster.yml`: initialize cluster
- `join-workers.yml`: join workers

## Setup
1. `ansible-playbook -i inventory.ini install-containerd.yml`
2. `ansible-playbook -i inventory.ini install-kube.yml`
3. `ansible-playbook -i inventory.ini init-cluster.yml`
4. `ansible-playbook -i inventory.ini join-workers.yml`

## Test
`kubectl get nodes`