Install Docker:
```bash
bash docker-íntall.sh
```

Setup Docker to start on boot:
```bash
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
```

User permissions:
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```