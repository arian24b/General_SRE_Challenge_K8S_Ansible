# Monitoring Alloy, Mimir, Alertmanager and Grafana

## Installation

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install mimir grafana/mimir-distributed
helm install alertmanager grafana/alertmanager -f alerts/alertmanager-values.yaml
helm install alloy grafana/alloy -f alloy-values.yaml
helm install grafana grafana/grafana -f grafana-values.yaml

echo "kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo"
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
