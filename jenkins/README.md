On k8s cluster, apply jenkins:
```bash
kubectl apply -f jenkins-rbac.yaml
kubectl config view --raw > jenkins-kubeconfig
scp jenkins-kubeconfig jenkins@<vm-jenkins-ip>:/var/jenkins_home/.kube/config
```

On another VM, where Jenkins setup:
```bash
docker compose up -d
```