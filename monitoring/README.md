# Monitoring Stack - Alloy, Mimir, Alertmanager and Grafana

## Automated Installation

The monitoring stack is automatically deployed via Ansible playbook:

```bash
cd infrastructure/ansible
ansible-playbook -i inventory.ini deploy-monitoring.yml
```

This playbook will:
- Install Mimir for metrics storage
- Install Alertmanager for alert routing
- Install Alloy for metrics collection
- Install Grafana with pre-configured dashboards
- Automatically provision datasources and dashboards

## Manual Installation (Alternative)

If you prefer to install manually:

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install mimir grafana/mimir-distributed --namespace monitoring
helm install alertmanager grafana/alertmanager -f alerts/alertmanager-values.yaml --namespace monitoring
helm install alloy grafana/alloy -f alloy-values.yaml --namespace monitoring
helm install grafana grafana/grafana -f grafana-values.yaml --namespace monitoring

# Get Grafana admin password
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

## Access:
- Grafana: `kubectl get svc grafana`
- Alertmanager: `kubectl get svc alertmanager`

## Alerting Rules:
- High CPU (>80%): warning
- Node Down: critical
- Pod Failed (>5 restarts): warning

## Notifications:
- Email critical alerts
