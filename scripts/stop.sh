#!/usr/bin/env bash
# Stop the Hugo dev server for this blog (kills whatever listens on port 1313)

pids=$(netstat -ano | grep -E ":1313 .*LISTENING" | awk '{print $NF}' | sort -u)

if [ -z "$pids" ]; then
  echo "Hugo server is not running on port 1313."
  exit 0
fi

for pid in $pids; do
  echo "Stopping hugo server (PID $pid)..."
  taskkill //PID "$pid" //F >/dev/null
done
