# PostgreSQL Cluster Deployment

## Setup:

```bash
helm repo add crunchydata https://charts.crunchydata.com
helm repo update

helm install postgres-operator crunchydata/postgres-operator --namespace application --create-namespace

kubectl wait --for=condition=available --timeout=300s deployment/postgres-operator --namespace application

kubectl apply -f postgres-cluster.yaml --namespace application

kubectl get pods -l postgres-operator.crunchydata.com/cluster=postgres-cluster --namespace application
```

## Access to DB:

```bash
kubectl get secret postgres-cluster-pguser-appuser --namespace application -o jsonpath='{.data.password}' | base64 -d

kubectl exec -it postgres-cluster-instance1-xxx --namespace application -- psql -U appuser -d postgres


kubectl get pods -l postgres-operator.crunchydata.com/cluster=postgres-cluster --namespace application

kubectl exec -it <pod-name> --namespace application -- psql -U appuser -d postgres -c "SELECT version();"
```

## Backup

- pgBackRest
- Two repos: repo1 and repo2
- Automatic backups
- Restore: `kubectl apply -f restore-job.yaml`

## Files:
- `postgres-cluster.yaml`: Cluster definition with 3 replicas and PVC
- `postgres-secret.yaml`: Credentials
- `postgres-service.yaml`: Service for access
