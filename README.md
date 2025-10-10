If you use k8s, run the following commands:
```bash
cd k8s-setup
bash setup-k8s-env.sh
bash on_first_master.sh
```

If you forget certs, run:
```bash
kubeadm init phase upload-certs --upload-certs
````

Upload the certificates and run the script on other master nodes:
```bash
bash on_other_master.sh
```

Make the master node to work as worker:
```bash
kubectl taint nodes node1 node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes node2 node-role.kubernetes.io/control-plane:NoSchedule-
kubectl taint nodes node3 node-role.kubernetes.io/control-plane:NoSchedule-
kubectl describe node node1
kubectl describe node node2
kubectl describe node node3
```

Check if ready:
```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system
```

Reset k8s cluster:
```bash
sudo kubeadm reset -f
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/kubernetes/manifests/*
sudo rm -rf /etc/cni/net.d
sudo rm $HOME/.kube/config
sudo crictl rm --all # remove all containers
sudo crictl rmi --all # remove all images
sudo systemctl restart containerd
```

```
sudo crictl ps -a
sudo systemctl stop kubelet
sudo rm -rf /var/lib/etcd/*
```