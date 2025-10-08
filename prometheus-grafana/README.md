Install Prometheus
```bash
bash prometheus-install.sh
```

Get Grafana password
```bash
kubectl get secret -n monitoring monitoring-grafana \
  -o jsonpath="{.data.admin-password}" | base64 --decode; echo
```