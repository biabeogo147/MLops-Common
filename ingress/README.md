Install ingress:
```bash
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