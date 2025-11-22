# PostgreSQL Cluster Deployment

## Automated Deployment

The PostgreSQL cluster is automatically deployed via Ansible playbook:

```bash
cd infrastructure/ansible
ansible-playbook -i inventory.ini deploy-postgres.yml
```

Then:
- Install the CrunchyData Postgres Operator
- Deploy a highly-available PostgreSQL cluster with 3 replicas
- Configure pgBackrest for backups
- Set up pgBouncer for connection pooling
- Create application users and databases
