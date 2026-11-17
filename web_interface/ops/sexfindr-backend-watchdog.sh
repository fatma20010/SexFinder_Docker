#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/opt/sexfindr/SexFinder_Docker/web_interface"
HEALTH_URL="http://127.0.0.1:5000/api/health"
TIMEOUT_SECONDS=8
LOG_FILE="/var/log/sexfindr-watchdog.log"

if ! curl -fsS --max-time "$TIMEOUT_SECONDS" "$HEALTH_URL" >/dev/null; then
  echo "$(date -Is) backend health failed -> restarting backend" >> "$LOG_FILE"
  /usr/bin/docker compose -f "$APP_DIR/docker-compose.yml" restart backend >> "$LOG_FILE" 2>&1
fi
