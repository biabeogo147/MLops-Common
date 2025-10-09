On k8s cluster, apply jenkins:
```bash
kubectl create namespace jenkins-cicd
kubectl apply -f jenkins-rbac.yaml
kubectl config view --raw | sudo tee jenkins-kubeconfig > /dev/null
scp jenkins-kubeconfig jenkins@<vm-jenkins-ip>:jenkins-kubeconfig
```

On another VM, where Jenkins setup:
```bash
nano Dockerfile.jenkins
# Add content in Dockerfile.jenkins
nano docker-compose.yml
# Add content in docker-compose.yml
docker compose up -d
```