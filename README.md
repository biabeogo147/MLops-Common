Install Docker and give permissions to your user.
```bash
cd MLops-Common
bash docker-íntall.sh
sudo groupadd docker
sudo usermod -aG docker $USER
```

Setup Docker to start on boot:
```bash
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

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

Install Helm/Ingress:
```bash
bash helm-install.sh
bash ingress-install.sh
```

Change port in /etc/nginx/sites-available/default
```nginx
server {
    listen 9999 default_server;
    listen [::]:999 default_server;
    ...
}
```

Create nginx conf: /etc/nginx/conf.d/domain_name.conf
```nginx
upstream my_servers {
    server 192.168.0.200:30080;
    server 192.168.0.201:30080;
    server 192.168.0.202:30080;
}

server {
    listen 80;

    location / {
        proxy_pass http://my_servers;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Test nginx config and restart:
```bash
sudo nginx -t
sudo systemctl restart nginx
```