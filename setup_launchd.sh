#!/usr/bin/env bash

set -euo pipefail

# Usage:
#   ./setup_launchd.sh /absolute/path/to/repo [hour] [minute]
#
# Example:
#   ./setup_launchd.sh /Users/ocean_dev2/stage/front-end-Monpatient 21 30

REPO_PATH="${1:-}"
HOUR="${2:-21}"
MINUTE="${3:-30}"
LABEL="com.oceandev.dailygit"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_DIR="$PROJECT_DIR/logs"

if [[ -z "$REPO_PATH" ]]; then
  echo "Error: repo path is required."
  echo "Usage: ./setup_launchd.sh /absolute/path/to/repo [hour] [minute]"
  exit 1
fi

if [[ ! -d "$REPO_PATH/.git" ]]; then
  echo "Error: '$REPO_PATH' is not a git repository."
  exit 1
fi

mkdir -p "$LOG_DIR"

cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
      <string>/bin/bash</string>
      <string>$PROJECT_DIR/daily_commit.sh</string>
      <string>$REPO_PATH</string>
      <string>10</string>
      <string>20</string>
    </array>

    <key>StartCalendarInterval</key>
    <dict>
      <key>Hour</key>
      <integer>$HOUR</integer>
      <key>Minute</key>
      <integer>$MINUTE</integer>
    </dict>

    <key>StandardOutPath</key>
    <string>$LOG_DIR/dailygit.out.log</string>
    <key>StandardErrorPath</key>
    <string>$LOG_DIR/dailygit.err.log</string>
  </dict>
</plist>
EOF

launchctl unload "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl load "$PLIST_PATH"

echo "Installed: $PLIST_PATH"
echo "Runs daily at $(printf '%02d:%02d' "$HOUR" "$MINUTE")"
echo "Check status: launchctl list | rg $LABEL"
