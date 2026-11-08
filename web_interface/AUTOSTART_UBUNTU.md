## Keep SexFindR Up After Reboot

Run these commands once on your Ubuntu droplet.

### 1) Ensure Docker starts at boot

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

### 2) Create a systemd service for this compose stack

```bash
sudo tee /etc/systemd/system/sexfindr.service >/dev/null <<'EOF'
[Unit]
Description=SexFindR Docker Compose Stack
Requires=docker.service
After=docker.service network-online.target

[Service]
Type=oneshot
WorkingDirectory=/opt/sexfindr/SexFinder_Docker/web_interface
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
RemainAfterExit=yes
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF
```

### 3) Enable and start the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable sexfindr.service
sudo systemctl start sexfindr.service
```

### 4) Verify

```bash
sudo systemctl status sexfindr.service --no-pager
cd /opt/sexfindr/SexFinder_Docker/web_interface
docker compose ps
```

### Optional: test reboot behavior

```bash
sudo reboot
```

After reconnecting, verify:

```bash
docker compose -f /opt/sexfindr/SexFinder_Docker/web_interface/docker-compose.yml ps
```
