## Backend Auto-Restart Watchdog (Ubuntu)

Install this once on the server to auto-restart backend if `/api/health` hangs.

```bash
sudo install -m 755 /opt/sexfindr/SexFinder_Docker/web_interface/ops/sexfindr-backend-watchdog.sh /usr/local/bin/sexfindr-backend-watchdog.sh
```

Add cron (every 5 minutes):

```bash
( sudo crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/sexfindr-backend-watchdog.sh" ) | sudo crontab -
```

Verify cron entry:

```bash
sudo crontab -l
```

Log file:

```bash
sudo tail -n 50 /var/log/sexfindr-watchdog.log
```
