I used source code from https://github.com/data-guru0/ANIME-RECOMMENDER-SYSTEM-LLMOPS and modified it based on my needs.

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

If you use Minikube, run the following commands:
```bash
cd minikube-setup
bash minikube-install.sh
bash kubectl-install.sh
minikube start
eval $(minikube docker-env)
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

Check if ready:
```bash
kubectl get nodes -o wide
kubectl get pods -n kube-system
```

Install Helm and Prometheus:
```bash
bash helm-install.sh
bash prometheus-install.sh
```

On-premise ingress setup:
```bash
bash ingress-install.sh
kubectl edit svc ingress-nginx-controller -n ingress-nginx
# Change type: LoadBalancer to type: NodePort
# Change nodePort http: "" => http: "30080"
# Change nodePort https: "" => https: "30443"  
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

Rancher setup (optional):
```bash
sudo mkfs.ext4 -m 0 /dev/sdb
mkdir /data
echo "/dev/sdb  /data  ext4  defaults  0  0" | sudo tee -a /etc/fstab
mount -a
sudo df -h

mkdir /data/rancher
cd /data/rancher
nano docker-compose.yml
```

Docker-compose file for Rancher:
```yaml
version: '3'
services:
  rancher-server:
    image: rancher/rancher:v2.9.2
    container_name: rancher-server
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /data/rancher/data:/var/lib/rancher
    privileged: true
```

Run Rancher and get the bootstrap password:
```bash
docker-compose up -d
docker logs rancher-server 2>&1 | grep "Bootstrap Password:"
```