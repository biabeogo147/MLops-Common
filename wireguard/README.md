# 1. Install WireGuard and necessary tools
```bash
bash wireguard-install.sh
```

# 2. Activate IP forwarding for IPv4 and IPv6 in sysctl.conf
```bash
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
sysctl -p
```

# 3. Create WireGuard UI directory and download the latest WireGuard UI binary
```bash
nano /etc/wireguard/start-wgui.sh
```

### 3.1. Content of start-wgui.sh
```bash
#!/bin/bash
cd /etc/wireguard
./wireguard-ui 192.168.100.113 0.0.0.0:5000
```

### 3.2. Add execute permission to the script
```bash
chmod +x start-wgui.sh
```

# 4. Create a systemd service (wgui-web.service) to start WireGuard UI on system boot
```bash
nano /etc/systemd/system/wgui-web.service
```

### 4.1 Content of wgui-web.service
```ini
[Unit]
Description=WireGuard UI
[Service]
Type=simple
ExecStart=/etc/wireguard/start-wgui.sh
[Install]
WantedBy=multi-user.target
```

# 5. Create an update script (update.sh) to automatically fetch the latest version of WireGuard UI from GitHub and restart the service
```bash
nano /etc/wireguard/update.sh
```

### 5.1. Content of update.sh
```bash
#!/bin/bash
VER=$(curl -s https://api.github.com/repos/ngoduykhanh/wireguard-ui/releases/latest | grep '"tag_name":' | cut -d '"' -f4)

if [[ -z "$VER" ]]; then
    echo "Error: Unable to fetch latest version."
    exit 1
fi

FILE="wireguard-ui-$VER-linux-amd64.tar.gz"
echo "Downloading $FILE"
curl -sL "https://github.com/ngoduykhanh/wireguard-ui/releases/download/$VER/$FILE" -o $FILE

if [[ -f "$FILE" ]]; then
    echo "Extracting $FILE"
    tar xvf $FILE || echo "Error extracting $FILE"
else
    echo "Download failed."
fi

echo "Restarting wgui-web.service"
systemctl restart wgui-web.service
```

### 5.2. Add execute permission and run
```bash
chmod +x /etc/wireguard/update.sh
cd /etc/wireguard
./update.sh
```

# 6. Create systemd service and path (wgui.service and wgui.path) to monitor and restart WireGuard when wg0.conf changes
```bash
nano /etc/systemd/system/wgui.service
nano /etc/systemd/system/wgui.path
```

### 6.1. Content of wgui.service
```ini
[Unit]
Description=Restart WireGuard
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/systemctl restart wg-quick@wg0.service

[Install]
RequiredBy=wgui.path
```

### 6.2. Content of wgui.path
```ini
[Unit]
Description=Watch /etc/wireguard/wg0.conf for changes

[Path]
PathModified=/etc/wireguard/wg0.conf

[Install]
WantedBy=multi-user.target
```

# 7. Activate and start the services
```bash
systemctl enable wgui.{path,service} wg-quick@wg0.service wgui-web.service
systemctl start wgui.{path,service}
```