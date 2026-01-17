#!/bin/bash

SCRIPT_PATH="$(realpath "$(dirname "$0")/update.sh")"
SERVICE_NAME="flatpak-update"
SERVICE_FILE="$HOME/.config/systemd/user/$SERVICE_NAME.service"
TIMER_FILE="$HOME/.config/systemd/user/$SERVICE_NAME.timer"

mkdir -p "$HOME/.config/systemd/user"

# Create Service File
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Update Flatpak Applications Daily

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH

[Install]
WantedBy=default.target
EOF

# Create Timer File (Runs daily, 15m after boot, then every 24h)
cat <<EOF > "$TIMER_FILE"
[Unit]
Description=Run Flatpak Update Daily

[Timer]
OnBootSec=15min
OnUnitActiveSec=1d
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Reload and Enable
systemctl --user daemon-reload
systemctl --user enable --now "$SERVICE_NAME.timer"

echo "Systemd timer created and started."
echo "You can check status with: systemctl --user status $SERVICE_NAME.timer"
